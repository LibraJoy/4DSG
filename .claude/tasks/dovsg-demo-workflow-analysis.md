# DovSG Demo: Complete End-to-End Workflow Analysis

## Executive Summary

This document provides a comprehensive, code-anchored analysis of the DovSG demo workflow. The analysis traces the complete execution path from the command-line entry point through all nine workflow steps, providing detailed code references and execution flow for developers.

**Command Analyzed**:
```bash
python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_scene_change_level "Minor Adjustment" \
    --task_description "Please move the red pepper to the plate, then move the green pepper to plate."
```

## Workflow Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        DovSG Demo Workflow                     │
│                                                                 │
│  Entry Point: demo.py ──> Controller Initialization            │
│                                                                 │
│  ┌───────────────────┐    ┌─────────────────────────────────┐  │
│  │  Preprocessing    │    │        Core Pipeline           │  │
│  │  (Steps 1-5)      │    │        (Steps 6-9)             │  │
│  │                   │    │                                 │  │
│  │  1. Data Collection│    │  6. 3DSG Construction         │  │
│  │  2. Pose Estimation│    │  7. LightGlue Features        │  │
│  │  3. Floor Transform│    │  8. Task Planning             │  │
│  │  4. ACE Training   │    │  9. Task Execution +          │  │
│  │  5. View Dataset   │    │     Continuous Updates        │  │
│  └───────────────────┘    └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Entry Point Analysis

### Demo.py Structure (`demo.py:1-91`)

**Main Function Signature** (`demo.py:5`)
```python
def main(args):
```

**Controller Initialization** (`demo.py:7-15`)
```python
controller = Controller(
    step=0,
    tags=args.tags,           # "room1"
    interval=3,
    resolution=0.01,          # 1cm voxel resolution
    occ_avoid_radius=0.2,     # 20cm obstacle avoidance
    save_memory=args.save_memory,
    debug=args.debug
)
```

**Argument Parser Configuration** (`demo.py:70-85`)
```python
parser.add_argument('--tags', type=str, default="room1", help='tags for scene.')
parser.add_argument('--preprocess', action='store_true', help='preprocess scene.')
parser.add_argument('--debug', action='store_true', help='For debug mode.')
parser.add_argument('--task_scene_change_level', type=str, default="Minor Adjustment",
                    choices=["Minor Adjustment", "Positional Shift", "Appearance"])
parser.add_argument('--task_description', type=str, default="", help='your task description.')
```

### Execution Flow Control (`demo.py:17-66`)

**Conditional Execution Logic**:
1. **Data Collection**: `if args.scanning_room:` (line 17) - Skipped in analysis command
2. **Preprocessing**: `if args.preprocess:` (line 22) - Executed (Steps 1-5)
3. **Core Pipeline**: Always executed (Steps 6-9)
4. **Task Execution**: `if not args.scanning_room:` (line 63) - Executed

## Detailed Workflow Step Analysis

### Steps 1-3: Data Collection, Pose Estimation, Coordinate Transformation

#### Step 1: Data Collection (`controller.py:159-179`)
**Code Reference**: `controller.data_collection()`
```python
def data_collection(self):
    if self.recorder_dir.exists():
        if input("Do you want to record data? [y/n]: ") == "n":
            return
    imagerecorder = RecorderImage(recorder_dir=self.recorder_dir)
    input("\033[32mPress any key to Start.\033[0m")
```

**Execution**: **SKIPPED** - Not called when `--preprocess` is used without `--scanning_room`

**Purpose**: Collect RGB-D data using handheld camera for new scenes

#### Step 2: Pose Estimation (`controller.py:181-193`)
**Code Reference**: `controller.pose_estimation()` (`demo.py:23`)
```python
def pose_estimation(self):
    print("\n\nPose Estimation in progress, please waiting for a moment...\n\n")
    process = subprocess.Popen([
        "conda", "run", "-n", "droidslam", "python", "pose_estimation.py",
        "--datadir", str(self.recorder_dir),           # data_example/room1
        "--calib", str(self.recorder_dir / "calib.txt"),
        "--pose_path", "poses_droidslam",
        "--stride", "1"
    ], cwd="dovsg/scripts", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    process.wait()
```

**Technology**: DROID-SLAM camera pose estimation
**Output**: Creates `poses_droidslam/` directory with pose files
**Integration**: Subprocess call to DROID-SLAM environment

#### Step 3: Coordinate Transformation (`controller.py:224-322`)
**Code Reference**: `controller.transform_pose_with_floor()` (`demo.py:29`)

**Sub-steps**:
1. **Floor Detection** (`lines 225-231`):
   ```python
   from dovsg.perception.models.mygroundingdinosam2 import MyGroundingDINOSAM2
   mygroundingdino_sam2 = MyGroundingDINOSAM2(
       box_threshold=0.8, text_threshold=0.8, nms_threshold=0.5
   )
   ```

2. **Floor Point Collection** (`lines 246-263`):
   ```python
   for cnt in tqdm(range(0, len(rgb_filepaths), self.interval)):
       detections = mygroundingdino_sam2.run(image=image, classes=["floor"])
       if len(detections.class_id) > 0:
           point_world = point @ pose[:3, :3].T + pose[:3, 3]
   ```

3. **Coordinate System Transform** (`lines 295-322`):
   ```python
   floor_normal, floor_inliers = self.process_floor_points(floor_xyzs)
   transformation_matrix = self.get_transformation_matrix_to_align_with_z_axis(floor_normal)
   # Apply transformation to all poses
   ```

**Purpose**: Transform DROID-SLAM poses to floor-aligned coordinate system

### Steps 4-5: ACE Training and View Dataset Generation

#### Step 4: ACE Training (`controller.py:423-428`)
**Code Reference**: `controller.train_ace()` (`demo.py:32`)
```python
def train_ace(self):
    print("Train ACE")
    _train_ace(self.recorder_dir, self.ace_network_path)
    print("Train ACE Over!")
```

**Import Reference** (`controller.py:13`):
```python
from ace.train_ace import train_ace as _train_ace
```

**Purpose**: Train relocalization model for later camera pose estimation
**Technology**: ACE (Absolute Camera Pose Estimation)
**Output**: Trained neural network saved to `ace_network_path`

#### Step 5: View Dataset Generation (`controller.py:810-830`)
**Code Reference**: `controller.get_view_dataset()` (`demo.py:39`)
```python
def get_view_dataset(self):
    if self.view_dataset_path.exists():
        print("\n\nFound cache view_dataset, loading it!\n\n")
        with open(self.view_dataset_path, 'rb') as f:
            self.view_dataset = pickle.load(f)
    else:
        from dovsg.memory.view_dataset import ViewDataset
        self.view_dataset = ViewDataset(
            self.recorder_dir,
            interval=self.interval,      # 3
            resolution=self.resolution,  # 0.01
            nb_neighbors=self.nb_neighbors,
            std_ratio=self.std_ratio
        )
```

**Caching Strategy**: Saves processed dataset to avoid recomputation
**Data Processing**: Combines RGB-D images, poses, and point clouds into unified dataset

### Steps 6-7: 3DSG Construction and LightGlue Feature Extraction

#### Step 6a: Semantic Memory (`controller.py:832-893`)
**Code Reference**: `controller.get_semantic_memory()` (`demo.py:40`)
**Purpose**: Initialize semantic segmentation and object detection models
**Technology**: Vision-Language Models (VLMs) for object recognition

#### Step 6b: Instance Objects (`controller.py:894-918`)
**Code Reference**: `controller.get_instances()` (`demo.py:41`)
```python
def get_instances(self):
    if self.instance_objects_path.exists():
        with open(self.instance_objects_path, "rb") as f:
            self.instance_objects = pickle.load(f)
    else:
        instance_process = InstanceProcess(
            downsample_voxel_size=self.resolution,
            part_level_classes=self.part_level_classes
        )
        self.instance_objects, self.object_filter_indexes = instance_process.get_instances(
            memory_dir=self.memory_dir,
            view_dataset=self.view_dataset,
        )
```

**Technology**: Instance segmentation and 3D object extraction
**Output**: `MapObjectList` containing detected 3D object instances

#### Step 6c: 3D Scene Graph Construction (`controller.py:920-940`)
**Code Reference**: `controller.get_instance_scene_graph()` (`demo.py:42`)
```python
def get_instance_scene_graph(self, is_visualize=True):
    if self.instance_scene_graph_path.exists():
        with open(self.instance_scene_graph_path, "rb") as f:
            self.instance_scene_graph = pickle.load(f)
    else:
        scenegraphprocesser = SceneGraphProcesser(
            part_level_classes=self.part_level_classes,
            resolution=self.resolution
        )
        self.instance_scene_graph = scenegraphprocesser.build_scene_graph(
            view_dataset=self.view_dataset,
            instance_objects=self.instance_objects
        )
    self.instance_scene_graph.visualize(save_dir=self.memory_dir)
```

**Core Algorithm**: Rule-based spatial relationship extraction
**Visualization**: Graphviz scene graph generation (`graph.py:53`)

#### Step 7: LightGlue Feature Extraction (`controller.py:942-950`)
**Code Reference**: `controller.get_lightglue_features()` (`demo.py:43`)
```python
def get_lightglue_features(self):
    if self.lightglue_features_path.exists():
        self.lightglue_features = torch.load(self.lightglue_features_path)
    else:
        featurematch = RGBFeatureMatch()
        append_length = self.view_dataset.append_length_log[-1]
        images = self.view_dataset.images[-append_length:]
        self.lightglue_features = featurematch.extract_memory_features(
            images=images, features=self.lightglue_features
        )
        torch.save(self.lightglue_features, self.lightglue_features_path)
```

**Purpose**: Extract visual features for relocalization assistance
**Technology**: LightGlue feature matching algorithm

### Steps 8-9: Task Planning and Execution with Continuous Updates

#### Step 8: LLM Task Planning (`controller.py:953-963`)
**Code Reference**: `controller.get_task_plan()` (`demo.py:64`)
```python
def get_task_plan(self, description: str, change_level: str):
    # Create task-specific memory directory
    self._memory_dir = self._memory_dir / f"{change_level} long_term_task: {description}"
    self._memory_dir.mkdir(exist_ok=True)
    self.create_memory_floder()

    taskplanning = TaskPlanning(save_dir=self._memory_dir)
    response = taskplanning.get_response(description=description)
    tasks = response["subtasks"]
    return tasks
```

**Input**: Natural language task description
**Output**: List of structured subtasks
**Technology**: Large Language Model (LLM) task decomposition

#### Step 9: Task Execution with Continuous Updates (`controller.py:1109-1424`)
**Code Reference**: `controller.run_tasks()` (`demo.py:66`)

**Execution Flow**:

1. **Initialization** (`lines 1110-1125`):
   ```python
   self.get_instance_localizer()
   self.get_pathplanning()
   observations, correct_success = self.get_align_observations(
       just_wrist=True, show_align=True, use_inlier_mask=True,
       self_align=False, align_to_world=True, save_name="0_start"
   )
   ```

2. **Task Loop** (`lines 1126-1200`):
   ```python
   for index, task in enumerate(tasks):
       if task["action"] == "Go to":
           self.go_to(object1=task["object1"], object2=task["object2"],
                     start_point=current_position, start_rotation=current_rotation)
       elif task["action"] == "Pick up":
           # Pick up execution logic
       elif task["action"] == "Place":
           # Place execution logic
   ```

3. **Continuous Scene Graph Updates** (`lines 1414-1416`):
   ```python
   print("====> update instance scene graph")
   self.update_scene_graph()
   ```

**Scene Graph Update Implementation** (`controller.py:1343-1355`):
```python
def update_scene_graph(self):
    scenegraphprocesser = SceneGraphProcesser(
        part_level_classes=self.part_level_classes,
        resolution=self.resolution
    )
    self.instance_scene_graph = scenegraphprocesser.update_scene_graph(
        view_dataset=self.view_dataset,
        instance_objects=self.instance_objects,
        history_scene_graph=self.instance_scene_graph
    )
    self.instance_scene_graph.visualize(save_dir=self.memory_dir)
```

## Data Flow and State Management

### Persistent State Storage

**Controller Paths** (`controller.py:98-140`):
```python
self.view_dataset_path = self.memory_dir / "view_dataset.pkl"
self.instance_objects_path = self.memory_dir / "instance_objects.pkl"
self.instance_scene_graph_path = self.memory_dir / "instance_scene_graph.pkl"
self.lightglue_features_path = self.memory_dir / "lightglue_features.pth"
self.ace_network_path = self.recorder_dir / "ace_network.pt"
```

**Caching Strategy**: Each major component checks for existing cache files before recomputation

### Memory Management Pattern

**Consistent Caching Logic**:
```python
if cache_path.exists():
    # Load from cache
    with open(cache_path, 'rb') as f:
        self.component = pickle.load(f)
else:
    # Compute component
    self.component = compute_component()
    # Save to cache (only at step 0)
    if self.step == 0:
        with open(cache_path, 'wb') as f:
            pickle.dump(self.component, f)
```

## Integration Analysis

### Key Dependencies

**Core Modules**:
- `dovsg.controller.Controller`: Main orchestration class
- `dovsg.memory.view_dataset.ViewDataset`: RGB-D data management
- `dovsg.memory.instances.instance_process.InstanceProcess`: 3D object detection
- `dovsg.memory.scene_graph.scene_graph_processer.SceneGraphProcesser`: Scene graph construction
- `dovsg.task_planning.gpt_task_planning.TaskPlanning`: LLM task planning

**External Systems**:
- **DROID-SLAM**: Camera pose estimation (separate conda environment)
- **ACE**: Neural relocalization training
- **GroundingDINO + SAM2**: Object detection and segmentation
- **LightGlue**: Visual feature matching

### Subprocess Integration

**DROID-SLAM Execution** (`controller.py:184-193`):
```python
process = subprocess.Popen([
    "conda", "run", "-n", "droidslam", "python", "pose_estimation.py",
    # ... arguments
], cwd="dovsg/scripts")
process.wait()
```

**Environment Isolation**: Uses separate conda environment for DROID-SLAM

## Performance and Execution Characteristics

### Computational Bottlenecks

1. **DROID-SLAM Pose Estimation**: Most time-intensive step (~minutes for full scene)
2. **ACE Training**: Neural network training for relocalization
3. **Instance Segmentation**: VLM-based object detection across all views
4. **Scene Graph Construction**: Spatial relationship analysis

### Caching Effectiveness

**Cache Hit Benefits**:
- ViewDataset: Avoids RGB-D processing (~seconds saved)
- Instance Objects: Avoids VLM inference (~minutes saved)
- Scene Graph: Avoids spatial analysis (~seconds saved)
- LightGlue Features: Avoids feature extraction (~minutes saved)

**Cache Miss Penalty**: Initial run requires full pipeline execution

## Error Handling and Robustness

### Critical Failure Points

**Pose Estimation Validation** (`controller.py:1120-1121`):
```python
if not correct_success:
    assert 1 == 0, "Init Pose Error!"
```

**File Existence Checks**: All major components verify cache file existence
**Subprocess Monitoring**: DROID-SLAM process completion is awaited

### Recovery Mechanisms

**Cache Invalidation**: Manual deletion of cache files forces recomputation
**Step-wise Execution**: Can be run with different argument combinations
**Debug Mode**: `--debug` flag enables detailed logging

## Future Extension Points

### Workflow Modularity

**Independent Steps**: Each major step can be executed independently with appropriate caches
**Parameter Tuning**: Key parameters exposed through Controller initialization
**Plugin Architecture**: New perception/planning modules can be integrated

### Scalability Considerations

**Memory Usage**: Large scenes may require memory optimization
**Processing Time**: Parallel processing opportunities in view dataset creation
**Model Updates**: VLM and LLM components can be updated independently

## Conclusion

The DovSG demo workflow represents a sophisticated integration of multiple AI systems:

**Strengths**:
- **Comprehensive Pipeline**: Covers complete robotics manipulation workflow
- **Robust Caching**: Efficient development and testing cycles
- **Modular Design**: Clear separation of concerns across workflow steps
- **State Persistence**: Reliable state management across execution sessions

**Complex Integration**:
- **Multi-Environment**: Coordinates multiple conda environments seamlessly
- **External Dependencies**: Robust handling of DROID-SLAM subprocess execution
- **Large Model Integration**: Efficient VLM and LLM integration patterns

**Production Readiness**:
- **Error Handling**: Critical failure points identified and handled
- **Performance Optimization**: Caching reduces repeated computation costs
- **Debugging Support**: Debug modes and logging facilitate development

This analysis provides developers with complete understanding of the DovSG workflow execution, enabling effective debugging, extension, and optimization of the system.

---

**Document Version**: 1.0
**Analysis Date**: January 2025
**Code Base**: DovSG Docker Environment
**Scope**: Complete demo.py workflow with preprocessing and task execution