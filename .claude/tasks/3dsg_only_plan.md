# 3DSG-Only Pipeline Simplification Plan

## 1. Pipeline Map (Evidence)
| Stage | Module / Function | Trigger (CLI / Flag) | Outputs / Artifacts | Essential? |
| --- | --- | --- | --- | --- |
| Pose estimation (DROID-SLAM) | `dovsg/controller.py:184-197` → `Controller.pose_estimation()` (calls `dovsg/scripts/pose_estimation.py`) | `demo.py --preprocess` (line 18) | `data_example/<tag>/poses_droidslam/*.txt` | **Essential** (camera poses needed for 3DSG) |
| Floor alignment & mask prep | `Controller.transform_pose_with_floor()` (`controller.py:227-322`) | same preprocess block | `poses/*.txt` aligned to floor, masks for floor removal | **Essential** (aligns scene for consistent memory) |
| ACE training | `Controller.train_ace()` (`controller.py:324-367`) → `ace/train_ace.py` | invoked inside preprocess block; no CLI guard today | `data_example/<tag>/ace/ace.pt` | **Skippable** for 3DSG (used later for relocalization only) |
| Visualization before caching | `Controller.show_pointcloud()` (`controller.py:369-418`) | preprocess block (`demo.py:33-38`) | Open3D window only | Skippable (debug only) |
| View dataset fusion | `Controller.get_view_dataset()` (`controller.py:811-831`, `memory/view_dataset.py`) | always called in `demo.py` after preprocess branch | `memory/<suffix>/step_0/view_dataset.pkl` & voxel maps | **Essential** |
| Semantic detections | `Controller.get_semantic_memory()` (`controller.py:833-889`, `memory/ram_groundingdino_sam2_clip_semantic_memory.py`) | always called (`demo.py:42`) | `.../semantic_memory/*.pkl`, `classes_and_colors.json`, `visualize/*.jpg` | **Essential** |
| Instance fusion | `Controller.get_instances()` (`controller.py:895-918`, `memory/instances/instance_process.py`) | `demo.py:43` | `.../instance_objects.pkl` | **Essential** |
| Scene graph build | `Controller.get_instance_scene_graph()` (`controller.py:921-938`, `memory/scene_graph/scene_graph_processer.py`) | `demo.py:44` | `.../instance_scene_graph.pkl`, `scene_graph.pdf` | **Essential** |
| LightGlue feature extraction | `Controller.get_lightglue_features()` (`controller.py:929-947`) | `demo.py:45` | `.../lightglue_features.pt` | Skippable for 3DSG viewer (used for localization) |
| 3DSG visualization | `Controller.show_instances()` (`controller.py:1181-1206`, `memory/instances/visualize_instances.py`) | `demo.py:52-62` (`clip_vis=True`) | Open3D viewer windows | **Essential** for interactive output |
| Task planning / ACE usage | `Controller.get_task_plan()` etc. (`controller.py:954+`) | only when `--skip_task_planning` NOT set | Long-term task directories | **Skippable** (disable via `--skip_task_planning`) |

## 2. Essential vs Skippable Summary
- **Essential for 3DSG:** Pose estimation, floor alignment, view dataset, semantic memory, instance fusion, scene graph, viewer.
- **Skippable (safe to omit):**
  - ACE training (`Controller.train_ace()`): produces `ace/ace.pt` for relocalization; not read by 3DSG viewer.
  - Intermediate visualization (`show_droidslam_pointcloud`, `show_pointcloud`).
  - LightGlue feature extraction (`get_lightglue_features`) when not running localization.
  - Task planning (already avoided with `--skip_task_planning`).

**Disable knobs (no edits yet):**
- ACE: would require a new CLI guard (e.g., `--skip_ace`). `demo.py` currently has no flag; proposal in §3.
- LightGlue: similarly can be behind a flag (`--skip_lightglue`) or run conditionally.

## 3. Proposed 3DSG-Only Run Path
1. Start containers: `cd docker && ./scripts/docker_run.sh`.
2. (Optional) clear stale memory: `docker compose exec dovsg bash -lc 'rm -rf /app/data_example/room1/memory/3_0.1_0.01_True_0.2_0.5/step_0'`.
3. Preprocess essentials (pose, floor, semantic, instances, scene graph) **without ACE** *(proposal)*: `docker compose exec dovsg python -u demo.py --tags room1 --preprocess --debug --skip_task_planning --skip_ace --skip_lightglue`.
4. Launch viewer on cached artifacts: `cd docker && ./scripts/run_3dsg_only.sh room1` (already skips preprocessing).
5. Use Open3D window (keyboard controls) to inspect 3DSG.

### Proposed (not applied) diffs
- Add optional flags in `demo.py` (and pass-through to `Controller`):
  ```diff
   parser.add_argument('--preprocess', action='store_true', help='preprocess scene.')
+  parser.add_argument('--skip_ace', action='store_true', help='Skip ACE training during preprocess.')
+  parser.add_argument('--skip_lightglue', action='store_true', help='Skip LightGlue feature extraction.')
  ...
-  if args.preprocess:
+  if args.preprocess:
       controller.pose_estimation()
       controller.show_droidslam_pointcloud(...)
       controller.transform_pose_with_floor(...)
-      controller.train_ace()
+      if not args.skip_ace:
+          controller.train_ace()
       controller.show_pointcloud(...)
  ...
-  controller.get_lightglue_features()
+  if not args.skip_lightglue:
+      controller.get_lightglue_features()
  ```
- Ensure `Controller.get_lightglue_features` tolerates skip (already optional if not called).

## 4. Validation Commands (post-implementation)
```bash
# Regenerate 3DSG caches without ACE/lightglue
docker compose exec dovsg python -u demo.py --tags room1 --preprocess --debug --skip_task_planning --skip_ace --skip_lightglue

# Confirm artifacts
docker compose exec dovsg bash -lc '
  ls -lh /app/data_example/room1/memory/3_0.1_0.01_True_0.2_0.5/step_0
  python - <<"PY"
import pickle, pathlib
base = pathlib.Path("/app/data_example/room1/memory/3_0.1_0.01_True_0.2_0.5/step_0")
print("instances:", len(pickle.load((base/"instance_objects.pkl").open("rb"))))
print("scene_graph nodes:", len(pickle.load((base/"instance_scene_graph.pkl").open("rb")).object_nodes))
PY
'

# Launch 3DSG-only viewer
cd docker && ./scripts/run_3dsg_only.sh room1
```
Success criteria: semantic files non-empty, `instance_objects.pkl` has >0 entries, Open3D viewer renders colored objects (not just floor), keyboard controls respond.

## 5. Risks & Rollback
- Skipping ACE/lightglue removes relocalization capabilities; re-enable by running without `--skip_*` flags.
- If new flags are added, default behavior must remain unchanged (flags opt-in). Revert by removing the `--skip_ace`/`--skip_lightglue` edits from `demo.py`.
- If semantic detection still fails (due to stub detectors), the viewer may remain empty; rerun with default pipeline to confirm baseline.

## Optional Alignment
- **Is ACE training required for 3DSG?** — No. `Controller.train_ace()` (`controller.py:324-367`) only produces the ACE model for relocalization; 3DSG viewer never reads that artifact.
- **How to disable ACE?** — Proposed flag `--skip_ace` in `demo.py`, guarding the call in the preprocess block (as shown above).
