# 3DSG-Only Execution Plan

**Document Version**: 1.0
**Last Updated**: January 2025
**Purpose**: Streamlined execution of DovSG 3D Scene Graph construction and visualization

## Quick Start Commands

### Prerequisites
```bash
# 1. Start Docker containers
cd /home/cerlab/4DSG/docker
docker-compose up -d

# 2. Enable X11 forwarding (for GUI)
xhost +local:docker

# 3. Verify containers are running
docker-compose ps
```

### Full Pipeline (First Time)
```bash
# Run complete preprocessing (generates required artifacts)
docker exec dovsg-main conda run -n dovsg python demo.py --tags room1 --preprocess
```

### 3DSG-Only Pipeline (After Preprocessing)
```bash
# Option 1: Use dedicated script (recommended)
cd /home/cerlab/4DSG/docker
./scripts/run_3dsg_only.sh room1

# Option 2: Direct command
docker exec dovsg-main conda run -n dovsg python demo.py --tags room1
```

## Code Path Overview

### Core Processing Flow
```
demo.py:39-61 → Controller methods → Interactive 3DSG Viewer
```

### Key Functions Called
1. **`controller.get_view_dataset()`** (line 39)
   - **Purpose**: Load preprocessed view dataset from memory cache
   - **Input**: `data_example/room1/memory/`
   - **Output**: View dataset with poses, images, and point cloud mapping

2. **`controller.get_semantic_memory()`** (line 40)
   - **Purpose**: Object detection and semantic segmentation using RAM + GroundingDINO + SAM2
   - **Input**: RGB images from view dataset
   - **Output**: `data_example/room1/semantic_memory/` (detection results)

3. **`controller.get_instances()`** (line 41)
   - **Purpose**: Instance segmentation and object clustering
   - **Input**: Semantic memory results
   - **Output**: `data_example/room1/instances/` (object instances)

4. **`controller.get_instance_scene_graph()`** (line 42)
   - **Purpose**: **3DSG Construction** - builds spatial relationships between instances
   - **Input**: Object instances + spatial positions
   - **Output**: 3D Scene Graph with nodes (objects) and edges (relationships)

5. **`controller.get_lightglue_features()`** (line 43)
   - **Purpose**: Extract visual features for relocalization
   - **Input**: RGB images
   - **Output**: Feature descriptors for image matching

6. **`controller.show_instances()`** (lines 56-61)
   - **Purpose**: **Interactive 3DSG Viewer** - the final visualization
   - **Input**: Instance objects + scene graph
   - **Output**: OpenGL window (1280x720) with keyboard controls

### Artifacts Produced

**Required for 3DSG-only execution:**
- `data_example/room1/poses_droidslam/` - Camera poses from DROID-SLAM
- `data_example/room1/memory/` - Preprocessed view dataset
- `data_example/room1/ace/` - ACE relocalization model

**Generated during 3DSG pipeline:**
- `data_example/room1/semantic_memory/` - Object detection results (.pkl files)
- `data_example/room1/instances/` - Instance segmentation results
- `data_example/room1/instance_scene_graph.pkl` - **The 3DSG data structure**

## Interactive 3DSG Viewer Controls

**Window**: OpenGL visualization (1280x720 pixels)

**Keyboard Controls:**
- **B** - Toggle background point cloud visibility
- **C** - Color objects by semantic class (red=objects, green=surfaces, etc.)
- **R** - Color objects by RGB appearance (natural colors)
- **F** - Color by CLIP feature similarity (semantic similarity highlighting)
- **G** - Toggle scene graph relationship lines (spatial edges between objects)
- **I** - Color by instance ID (unique color per detected object)
- **O** - Toggle 3D bounding boxes around objects
- **V** - Save current view parameters (camera position, zoom)

**Mouse Controls:**
- **Left drag** - Rotate camera view
- **Right drag** - Pan camera position
- **Scroll wheel** - Zoom in/out

## Environment Variables

**Required:**
- `DISPLAY=:0` - X11 display for GUI (set in docker-compose.yml)
- `PYTHONUNBUFFERED=1` - Real-time output (set in docker-compose.yml)

**GPU Access:**
- `NVIDIA_VISIBLE_DEVICES=all`
- `NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute`

## Acceptance Checks

### ✓ Successful Execution
1. **No crashes** during semantic memory initialization
2. **Real-time logging** appears during processing (not buffered)
3. **Three GUI windows** open during preprocessing:
   - DROID-SLAM point cloud
   - View dataset point cloud
   - Interactive 3DSG viewer
4. **Interactive controls** respond in final viewer window
5. **Scene graph relationships** visible when pressing 'G'

### ❌ Common Failure Modes & Fixes

**TypeError: unexpected keyword argument 'device'**
```bash
# Fix: Edit MyGroundingDINOSAM2 constructor
# File: /home/cerlab/4DSG/DovSG/dovsg/perception/models/mygroundingdinosam2.py
# Add: device="cuda" parameter to __init__
```

**Permission denied editing files**
```bash
sudo chown -R cerlab:cerlab /home/cerlab/4DSG/DovSG/
```

**Container not running**
```bash
cd /home/cerlab/4DSG/docker
docker-compose up -d
```

**X11 GUI not working**
```bash
xhost +local:docker
export DISPLAY=:0
```

**Missing artifacts (poses_droidslam, memory)**
```bash
# Run full preprocessing first
docker exec dovsg-main conda run -n dovsg python demo.py --tags room1 --preprocess
```

## File Structure Summary

```
data_example/room1/
├── poses_droidslam/        # DROID-SLAM camera poses (required)
├── memory/                 # View dataset cache (required)
├── ace/                    # ACE relocalization model (required)
├── semantic_memory/        # Object detection results (generated)
├── instances/              # Instance segmentation (generated)
└── instance_scene_graph.pkl # 3DSG data structure (generated)
```

## Development Notes

**Live Code Editing**: Changes to Python files in `/home/cerlab/4DSG/DovSG/` are immediately reflected in the container (volume mount).

**No Rebuild Required**: Only Docker image rebuild needed if changing dependencies in Dockerfile.

**GPU Memory**: ~5-7GB VRAM used during full pipeline execution.

**Processing Time**:
- Full preprocessing: 15-30 minutes
- 3DSG-only: 5-10 minutes
- Interactive viewer: Real-time