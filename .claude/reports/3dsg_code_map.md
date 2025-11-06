# DovSG 3DSG Code Map

## 1. Entry Points & Call Flow
- `DovSG/demo.py:6-85`
  - `main(args)` – CLI entry that instantiates `Controller`, runs optional preprocessing (`pose_estimation` → `show_droidslam_pointcloud` → `transform_pose_with_floor` → `train_ace`), then executes the steady-state pipeline (`get_view_dataset` → `get_semantic_memory` → `get_instances` → `get_instance_scene_graph` → `get_lightglue_features` → `show_instances`) before optional task planning.
- `DovSG/dovsg/controller.py:46-1245`
  - `Controller.__init__` – wires CLI options into paths (`RECORDER_DIR/<tags>`), thresholds, and cache locations.
  - `pose_estimation()` – launches `dovsg/scripts/pose_estimation.py` via `conda run` to produce `poses_droidslam` (Paper §III.A).
  - `show_droidslam_pointcloud()` / `show_pointcloud()` – diagnostic Open3D viewers over raw and aligned poses.
  - `transform_pose_with_floor()` – GroundingDINO+SAM2 plane detect + RANSAC to align floor (Paper §III.A).
  - `train_ace()` – delegates to `ace.train_ace` for relocalization descriptors.
  - `get_view_dataset()` – loads or builds the fused view cache via `ViewDataset`.
  - `get_semantic_memory()` – runs open-vocab detection + CLIP featurization with `RamGroundingDinoSAM2ClipDataset`.
  - `get_instances()` – fuses detections into instance tracks using `InstanceProcess`.
  - `get_instance_scene_graph()` – invokes `SceneGraphProcesser.build_scene_graph` and persists/visualizes the graph (Paper §III.C).
  - `get_lightglue_features()` – caches LightGlue embeddings for relocalization (Paper §III.B).
  - `show_instances()` – hands the assembled state to the Open3D viewer (`vis_instances`).
- `DovSG/dovsg/memory/view_dataset.py:24-210`
  - `ViewDataset.__init__` – gathers RGB/point/mask/pose streams, computes bounds, voxel grids, and append logs (Paper §III.A).
  - `voxelize`, `index_to_point`, `index_to_pcd` – utilities for voxel ↔ world conversions consumed downstream.
- `DovSG/dovsg/memory/ram_groundingdino_sam2_clip_semantic_memory.py` *(imported in controller)*
  - `RamGroundingDinoSAM2ClipDataset.semantic_process` – detects/segments open-vocab masks and embeds CLIP features (Paper §III.B).
- `DovSG/dovsg/memory/instances/instance_process.py:24-266`
  - `InstanceProcess.get_instances` – converts frame-level detections into persistent `MapObjectList` entries via spatial/visual/text similarity, filtering, and DBSCAN denoising (Paper §III.B).
  - Helper methods (`compute_*_similarities`, `merge_detections_to_objects`, `filter_objects`) support the association loop.
- `DovSG/dovsg/memory/scene_graph/scene_graph_processer.py:28-563`
  - `SceneGraphProcesser.build_scene_graph` – anchors floor root, infers support/containment/part links using alpha shapes, z-ordering, and FAISS proximity; enriches part relationships (Paper §III.C).
- `DovSG/dovsg/memory/scene_graph/graph.py:1-79`
  - `SceneGraph` / `ObjectNode` – in-memory DAG plus Graphviz export for inspection.
- `DovSG/dovsg/memory/instances/visualize_instances.py:1-296`
  - `vis_instances` – assembles Open3D geometries (background, per-instance point clouds, bounding-box line meshes, graph edges), wires keyboard callbacks, and optionally performs CLIP queries before rendering.
- Supporting scripts
  - `DovSG/dovsg/scripts/pose_estimation.py` – wraps DROID-SLAM inference (Paper §III.A).
  - `DovSG/dovsg/scripts/show_pointcloud.py` – CLI for debugging pose clouds (`--pose_tags` switch).
  - `DovSG/dovsg/scripts/rgb_feature_match.py` – defines `RGBFeatureMatch.extract_memory_features` used by `get_lightglue_features`.

**Call-chain summary:** `demo.py.main` → `Controller.pose_estimation*` → `Controller.transform_pose_with_floor*` → `Controller.get_view_dataset` (`ViewDataset`) → `Controller.get_semantic_memory` (`RamGroundingDino…`) → `Controller.get_instances` (`InstanceProcess`) → `Controller.get_instance_scene_graph` (`SceneGraphProcesser` + `SceneGraph`) → `Controller.show_instances` (`vis_instances` viewer) → optional `Controller.get_task_plan`. (*asterisked steps run only when `--preprocess` is set.)

## 2. Dataflow Table
| Stage (Paper) | Module / File | Key Functions | Inputs → Outputs | Notes |
| --- | --- | --- | --- | --- |
| Data capture (III.A) | `dovsg/controller.py:150-213`; `dovsg/scripts/pose_estimation.py` | `Controller.pose_estimation` | `RECORDER_DIR/<tag>/{rgb,depth,mask,point,calib}` → `poses_droidslam/*.txt` (camera-to-world) | Executes DROID-SLAM via subprocess; stride fixed to 1 to match paper’s dense trajectories. |
| Floor alignment (III.A) | `dovsg/controller.py:214-334` | `transform_pose_with_floor`, `process_floor_points`, `ransac_plane_fitting` | `poses_droidslam`, SAM2 floor masks → corrected `poses/*.txt`, floor-aligned point clouds | Uses GroundingDINO+SAM2 to isolate floor, RANSAC to align z-axis, matches paper’s coordinate reset. |
| View dataset fusion (III.A→III.B) | `dovsg/memory/view_dataset.py:24-210` | `ViewDataset.__init__`, `load_data`, `voxelize` | RGB/point/mask/poses → voxel grid metadata, per-frame voxel mappings, `view_dataset.pkl` | Builds global bounds & append logs; caches to avoid recomputation when `save_memory`. |
| Semantic memory (III.B) | `dovsg/controller.py:846-909`; `dovsg/memory/ram_groundingdino_sam2_clip_semantic_memory.py` | `get_semantic_memory`, `RamGroundingDinoSAM2ClipDataset.semantic_process` | ViewDataset frames → detection pickles (`memory/semantic_memory/*.pkl`), `classes_and_colors.json` | Generates open-vocab detections, CLIP features, optional annotated JPGs in `memory/visualize/`. |
| Instance fusion (III.B) | `dovsg/memory/instances/instance_process.py:24-266` | `InstanceProcess.get_instances` | Semantic pickles + voxel mappings → `instance_objects.pkl`, `object_filter_indexes` | Aggregates detections across time via similarity matrices and DBSCAN denoising; enforces unique voxel ownership. |
| Scene graph build (III.C) | `dovsg/memory/scene_graph/scene_graph_processer.py:308-563`; `dovsg/memory/scene_graph/graph.py` | `SceneGraphProcesser.build_scene_graph`, `SceneGraph.add_node`, `SceneGraph.visualize` | Instances + view dataset → `instance_scene_graph.pkl`, Graphviz `scene_graph` diagram | Infers `on` / `inside` / `belong` relationships using alpha-shapes, z-order, FAISS nearest neighbors; renders DAG to disk. |
| LightGlue features (III.B) | `dovsg/controller.py:929-946`; `dovsg/scripts/rgb_feature_match.py` | `get_lightglue_features`, `RGBFeatureMatch.extract_memory_features` | Latest RGB frames → `lightglue_features.pt` | Supports relocalization; no direct impact on viewer but required for downstream tasks. |
| Visualization (III.C) | `dovsg/controller.py:1181-1206`; `dovsg/memory/instances/visualize_instances.py:1-296` | `show_instances`, `vis_instances` | Instances + scene graph + class colors → Open3D window, optional `scene_graph` Graphviz PDF | Integrates background cloud, instance geometries, CLIP queries, keyboard toggles. |

## 3. CLI / Config Mapping
- `--tags` (`demo.py:60`) → `Controller.__init__` (`controller.py:72-108`) sets `self.recorder_dir = RECORDER_DIR / tags`, selecting `data_example/<tags>` for all IO caches.
- `--save_memory` (`demo.py:61`) → `Controller.__init__` toggles whether staged outputs (`view_dataset.pkl`, `instance_objects.pkl`, etc.) persist under `memory/<suffix>/step_<n>/`.
- `--preprocess` (`demo.py:18-40`) → gates the DROID-SLAM + floor alignment block; without it the pipeline assumes cached `poses/` and `memory/` exist.
- `--scanning_room` (`demo.py:16`) → triggers `Controller.data_collection` for new RGB-D capture before preprocessing.
- `--debug` (`demo.py:15`) → propagated to `Controller.debug`; allows reuse of previous caches (`controller.py:476, 1013, 1037, 1073, 1085, 1097`) when artifacts already exist.
- `--skip_task_planning` (`demo.py:52`) → prevents the post-visualization GPT task planner (`controller.py:1216-1250`) from running without API credentials.
- `--task_description`, `--task_scene_change_level` → forwarded to `Controller.get_task_plan` to create per-task memory branches.
- `show_pointcloud.py --tags/--pose_tags` (`dovsg/scripts/show_pointcloud.py:118-122`) → selects which pose directory (`poses_droidslam` vs `poses`) to render for debugging.
- Environment: Docker sets `PYTHONUNBUFFERED=1` (see `docker/docker-compose.yml`) to flush controller logs during long preprocessing runs; `RECORDER_DIR` is defined in `dovsg/utils/utils.py:45` and controls the base data root.

## 4. Visualization Controls & I/O
- Key bindings registered in `dovsg/memory/instances/visualize_instances.py:252-263`:
  - `B` (`toggle_bg_pcd`) – toggles background voxel cloud.
  - `C` (`color_by_class`) – paints by semantic class (`classes_and_colors`).
  - `R` (`color_by_rgb`) – restores original colors.
  - `A` (`color_by_clip_sim`) – prompts for text query, recolors by CLIP similarity (fallback query `"object"` if `input()` raises `EOFError`, lines 207-236).
  - `G` (`toggle_scene_graph`) – shows/hides scene graph nodes/edges.
  - `I` (`color_by_instance`) – assigns distinct colors per instance.
  - `O` (`toggle_bbox`) – toggles per-instance line-mesh bounding boxes.
  - `V` (`save_view_params`) – writes `temp.json` camera parameters.
- `clip_vis` flag (`Controller.show_instances`, `controller.py:1188`) drives whether `MyClip` is instantiated; set to `True` in `demo.py` to enable CLIP prompts.
- Headless bypass recommendation: expose a `--clip-no-input` (TODO) that injects a default query instead of calling `input()`; current fallback is triggered only after `EOFError`, so scripted runs should set `clip_vis=False` until a proper flag is added.

## 5. Gaps & TODOs
- `controller.transform_pose_with_floor` still launches blocking Open3D previews (`draw_geometries`, lines 276-322); add a headless flag or reuse cached detection masks for automated runs.
- `visualize_instances.py` hard-filters specific class_ids (`doll_17`, `plate_5`, lines 133-136); confirm if this was debug-only or should be parameterized.
- Scene graph FAISS-based parent search (`scene_graph_processer.py:456-528`) assumes Euclidean scale without normalization; revisit thresholds when voxel size changes.
- CLIP query path lacks explicit `--clip-query` CLI; consider plumbing via `demo.py` args to avoid stdin (visualization lines 207-236).
- Ensure `instance_scene_graph.visualize` Graphviz dependency remains optional (requires `graphviz` binary); document fallback for environments without it.
