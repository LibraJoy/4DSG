# 1) Overview of `dovsg/memory`
The memory subsystem caches every intermediate representation required to build and replay a Dense Open-Vocabulary 3D Scene Graph (3DSG). Each module under `DovSG/dovsg/memory/` converts raw RGB-D captures into reusable artifacts—pose-aligned point clouds, semantic detections, fused object instances, and the final scene graph—so subsequent runs can skip expensive stages.

Key modules (single line role each):
- `dovsg/memory/view_dataset.py` – builds the fused voxelized scene (`ViewDataset`) from RGB-D + poses (loaded/saved by `Controller.get_view_dataset`).
- `dovsg/memory/ram_groundingdino_sam2_clip_semantic_memory.py` – wraps RAM + GroundingDINO + SAM2 + CLIP to generate semantic detections (`get_semantic_memory`).
- `dovsg/memory/instances/instance_process.py` – merges detections over time, returning a `MapObjectList` of instance-level objects saved in `instance_objects.pkl`.
- `dovsg/memory/instances/visualize_instances.py` – renders cached data in Open3D and handles keyboard controls/CLIP queries.
- `dovsg/memory/scene_graph/scene_graph_processer.py` – builds the hierarchical 3DSG from instances; `graph.py` serializes it to disk/Graphviz.

# 2) Directory Schema & Naming
When `demo.py` runs, `Controller.__init__` builds a suffix (line 76): `suffix = "{interval}_{min_height}_{resolution}_{conservative}_{box_threshold}_{nms_threshold}"`. Artifacts land under:

```
data_example/<TAGS>/memory/<suffix>/
└── step_<N>/                # created by Controller.create_memory_floder (lines 136-161)
    ├── view_dataset.pkl
    ├── semantic_memory/000000.pkl …
    ├── visualize/*.jpg
    ├── classes_and_colors.json
    ├── instance_objects.pkl
    ├── instance_scene_graph.pkl
    ├── lightglue_features.pt
    ├── scene_graph.pdf / scene_graph/  (Graphviz output)
    └── pointcloud_droidslam_False.ply (optional cache)
```

Long-term task executions append nested directories (line 958): `memory/<suffix>/<change_level> long_term_task: <description>/step_<k>/…`.

# 3) Artifacts Table (who writes/reads what)
| Artifact | Producer (`file:function`) | Consumer(s) | Created When (Stage/CLI) | Expected Contents | Location |
| --- | --- | --- | --- | --- | --- |
| `view_dataset.pkl` | `dovsg/controller.py:811-831` `Controller.get_view_dataset` | Same function (reuse), `InstanceProcess.get_instances`, viewer | During preprocessing or first `demo.py` call | Pickled `ViewDataset` (images, masks, voxel map) | `memory/<suffix>/step_<n>/view_dataset.pkl` |
| `semantic_memory/*.pkl` | `Controller.get_semantic_memory` (`controller.py:833-889`) | `InstanceProcess.get_instances` (`instance_process.py:105-138`) | After detections (RAM + GDINO + SAM2) | Dict with `xyxy`, `mask`, `class_id`, CLIP feats | `…/semantic_memory/{frame}.pkl` |
| `classes_and_colors.json` | Same as above (`json.dump`) | Viewer coloring (`visualize_instances.py`) | Alongside semantic memory | JSON: `{ "classes": [...], "class_colors": {class: [r,g,b]} }` | `…/classes_and_colors.json` |
| `instance_objects.pkl` | `Controller.get_instances` (`controller.py:895-918`) → `InstanceProcess.get_instances` | Viewer (`visualize_instances.py`), scene graph builder, CLIP hotkey | After instance fusion (demo pipeline, 3DSG-only script) | Pickled `MapObjectList` of objects (`indexes`, `class_name`, `clip_ft`, etc.) | `…/instance_objects.pkl` |
| `instance_scene_graph.pkl` | `Controller.get_instance_scene_graph` (`controller.py:921-938`) | Scene graph visualization, task planning updates | Immediately after instances | Pickled `SceneGraph` object | `…/instance_scene_graph.pkl` |
| `lightglue_features.pt` | `Controller.get_lightglue_features` (`controller.py:929-947`) | Instance localization/path planning | After instance fusion | PyTorch tensor with LightGlue descriptors | `…/lightglue_features.pt` |
| `visualize/*.jpg` | `Controller.get_semantic_memory` (`controller.py:877-881`) | Manual inspection | When `--preprocess` or visualization enabled | Annotated detection overlays | `…/visualize/{frame}.jpg` |
| `scene_graph/`, `scene_graph.pdf` | `SceneGraph.visualize` (`scene_graph/graph.py:28-72`) called from controller | Manual inspection | After scene graph build | Graphviz DAG of scene hierarchy | `…/scene_graph/` & `scene_graph.pdf` |

# 4) Write/Read Map (code references)
- **view_dataset.pkl**  
  Write: `controller.py:827-831`  
  ```python
  with open(self.view_dataset_path, 'wb') as f:
      pickle.dump(self.view_dataset, f, protocol=4)
  ```  
  Read: `controller.py:814-818`
  ```python
  with open(self.view_dataset_path, 'rb') as f:
      self.view_dataset = pickle.load(f)
  ```

- **semantic memory pickles & visualization**  
  Write: `controller.py:871-885`  
  ```python
  det_res, annotated_image, image_pil = semantic_memory.semantic_process(image=image)
  with open(self.semantic_memory_dir / f"{name}.pkl", "wb") as f:
      pickle.dump(det_res, f)
  ```
  Read: `instance_process.py:105-112`  
  ```python
  with open(memory_dir / "semantic_memory" / f"{name}.pkl", "rb") as f:
      gsam2_obs = pickle.load(f)
  ```

- **instance_objects.pkl**  
  Write: `controller.py:915-918`  
  ```python
  if self.step == 0:
      with open(self.instance_objects_path, "wb") as f:
          pickle.dump(self.instance_objects, f)
  ```
  Read: `controller.py:897-900` (viewer/scene graph reuse)  
  Additional writes on step save: `controller.py:1376-1378`.

- **instance_scene_graph.pkl**  
  Write: `controller.py:935-938` and `controller.py:1379-1381`.  
  Read: `controller.py:921-924`.

- **lightglue_features.pt**  
  Write: `controller.py:948-952` & `1383-1384`  
  Read: `controller.py:933` (indirect via controller fields) / path planning modules.

- **scene_graph.pdf**  
  Generated inside `SceneGraph.visualize` (`scene_graph/graph.py:28-72`) invoked by `get_instance_scene_graph`.

# 5) Generation Flow & CLI Mapping
- Primary pipeline (`demo.py main`) calls, in order:  
  `Controller.get_view_dataset()` → `get_semantic_memory()` → `get_instances()` → `get_instance_scene_graph()` → `get_lightglue_features()` → `show_instances()`.  
  Each stage writes the artifacts listed above.
- Canonical commands (from docs/scripts):  
  - Full preprocessing: `docker compose exec dovsg python -u demo.py --tags room1 --preprocess --debug --skip_task_planning` (MANUAL_VERIFICATION Test 3.1).  
  - Cached 3DSG rerun: `docker compose exec dovsg python -u demo.py --tags room1 --skip_task_planning` or `./scripts/run_3dsg_only.sh room1`.  
  Flags:  
  - `--tags` selects `data_example/<tags>/memory/` via `Controller.recorder_dir`.  
  - `--preprocess` triggers pose estimation + semantic pipeline before caches are written.  
  - `--skip_task_planning` (optional) prevents long-term task directories from being created; caches still write.  
  - Instance/scene graph saving happens automatically when `save_memory=True` (default in `demo.py` CLI).

# 6) Validation & (Re)Generation Steps
```bash
# Ensure containers up
cd docker && ./scripts/docker_run.sh

# Regenerate preprocessing artifacts (if missing/stale)
docker compose exec dovsg python -u demo.py --tags room1 --preprocess --debug --skip_task_planning

# Quick health check
docker compose exec dovsg bash -lc '
  ls -lh /app/data_example/room1/memory/3_0.1_0.01_True_0.2_0.5/step_0
  python - <<\"PY\"
import pickle, pathlib
base = pathlib.Path("/app/data_example/room1/memory/3_0.1_0.01_True_0.2_0.5/step_0")
print("instance_count:", len(pickle.load((base/"instance_objects.pkl").open("rb"))))
print("scene_graph_nodes:", len(pickle.load((base/'instance_scene_graph.pkl').open("rb")).object_nodes))
PY
'

# Optional: rerun viewer with cached artifacts
cd docker && ./scripts/run_3dsg_only.sh room1
```

# 7) Troubleshooting
- **Empty `instance_objects.pkl`** – No semantic detections were produced (see `instance_process.py` loops). Regenerate via full preprocessing; ensure `data_example/<tags>/semantic_memory/*.pkl` exists.  
- **Wrong suffix directory** – Changed CLI defaults (e.g., `--interval`, `--box_threshold`) create a different `<suffix>`; list `memory/` to find current caches.  
- **Viewer commands do nothing** – The viewer loads an empty `instance_objects.pkl`; rebuild detections (commands above).  
- **Missing long-term task directories** – Only created when `Controller.get_task_plan` runs (requires API keys). For simple demos they are absent; this is expected.  
- **Stale visualizations** – Remove `memory/<suffix>/step_0` before rerunning to force regeneration (the pipeline skips stages if cached files already exist).
