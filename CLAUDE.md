# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Principles

### Code Style
- KISS: Write straightforward, uncomplicated solutions
- YAGNI: Implement only what's currently needed
- SOLID principles
- Never remove files outside this project (e.g., avoid `docker system prune -a`)
- Apply persistent fixes over temporary workarounds

### Planning & Review
- Always create a plan in `.claude/tasks/TASK_NAME.md` before starting work
- Update the plan with detailed descriptions as tasks are completed
- Ask for review approval before proceeding with implementation
- Think MVP - don't over-plan

## Project Overview

DovSG (Dense Open-Vocabulary 3D Scene Graphs) constructs dynamic 3D scene graphs for long-term language-guided mobile manipulation. This repository provides a complete Docker-based development environment that works across Ubuntu versions.

## Core Architecture

The pipeline is orchestrated by the `Controller` class ([DovSG/dovsg/controller.py](DovSG/dovsg/controller.py)):

1. **Data Collection** ([dovsg/scripts/realsense_recorder.py](DovSG/dovsg/scripts/realsense_recorder.py)): RGB-D image capture
2. **Pose Estimation** ([dovsg/scripts/pose_estimation.py](DovSG/dovsg/scripts/pose_estimation.py)): DROID-SLAM for camera poses
3. **Semantic Memory** ([dovsg/memory/ram_groundingdino_sam2_clip_semantic_memory.py](DovSG/dovsg/memory/ram_groundingdino_sam2_clip_semantic_memory.py)): Object detection with GroundingDINO + SAM2 + CLIP
4. **Instance Processing** ([dovsg/memory/instances/instance_process.py](DovSG/dovsg/memory/instances/instance_process.py)): Aggregate detections into object instances
5. **Scene Graph** ([dovsg/memory/scene_graph/scene_graph_processer.py](DovSG/dovsg/memory/scene_graph/scene_graph_processer.py)): Build spatial relationships
6. **Relocalization**: ACE pose estimation + LightGlue features for camera relocalization
7. **Task Planning** ([dovsg/task_planning/gpt_task_planning.py](DovSG/dovsg/task_planning/gpt_task_planning.py)): LLM-based task decomposition
8. **Navigation** ([dovsg/navigation/](DovSG/dovsg/navigation/)): A* pathfinding with occupancy maps

## Development Commands

All commands should be run from the `docker/` directory unless otherwise noted.

### Container Management
```bash
cd docker/

# Build containers (first time or after Dockerfile changes)
./scripts/docker_build.sh

# Start containers
./scripts/docker_run.sh

# Interactive shell
./scripts/docker_run.sh --shell

# Stop containers
docker compose down

# Clean up containers and volumes
./scripts/docker_clean.sh
```

### Running DovSG Pipeline

Full preprocessing (from `docker/` directory):
```bash
docker compose exec dovsg python -u demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --skip_task_planning
```

3DSG-only (skips heavy preprocessing when artifacts exist):
```bash
./scripts/run_3dsg_only.sh room1
```

With task planning:
```bash
docker compose exec dovsg python -u demo.py \
    --tags "room1" \
    --debug \
    --task_description "Move the red pepper to the plate"
```

### Individual Pipeline Steps

Pose estimation only:
```bash
docker compose exec dovsg python dovsg/scripts/pose_estimation.py \
    --datadir "data_example/room1" \
    --calib "data_example/room1/calib.txt" \
    --weights "checkpoints/droid-slam/droid.pth"
```

Visualize point cloud:
```bash
docker compose exec dovsg python dovsg/scripts/show_pointcloud.py \
    --tags "room1" \
    --pose_tags "poses_droidslam"
```

### Docker Services

- `dovsg`: Main DovSG environment (CUDA 12.1, PyTorch 2.3, Python 3.9)
- `droid-slam`: DROID-SLAM environment (CUDA 11.8, PyTorch 1.10, Python 3.9)
- `realsense-recorder`: Lightweight ROS Noetic container for ROS bag recording
- `roscore`: ROS master node (required for realsense-recorder)

Both dovsg and droid-slam services mount `DovSG/` for live code editing - no rebuild needed for Python changes.

### Interactive Viewer Controls

The 3DSG viewer ([dovsg/memory/instances/visualize_instances.py](DovSG/dovsg/memory/instances/visualize_instances.py)) supports these keyboard shortcuts:
- `B`: Toggle background point cloud
- `C`: Color by semantic class
- `R`: Color by RGB appearance
- `A`: Color by CLIP similarity
- `G`: Toggle scene graph relationships
- `I`: Color by instance ID
- `O`: Toggle bounding boxes
- `V`: Save current view parameters

## Key Configuration

### Demo Arguments ([demo.py](DovSG/demo.py))
- `--tags`: Scene identifier (e.g., "room1")
- `--preprocess`: Run pose estimation + ACE training + coordinate transforms
- `--scanning_room`: Data collection mode (requires real robot hardware)
- `--skip_ace`: Skip ACE training during preprocessing
- `--skip_lightglue`: Skip LightGlue feature extraction
- `--skip_task_planning`: Skip task planning (no API key required)
- `--semantic_device`: Device for RAM model (`cuda` or `cpu`)
- `--task_scene_change_level`: "Minor Adjustment", "Positional Shift", or "Appearance"
- `--debug`: Enable debug output

### Controller Parameters ([dovsg/controller.py](DovSG/dovsg/controller.py))
- `interval`: View sampling interval (default: 3)
- `resolution`: Occupancy map resolution in meters (default: 0.02)
- `occ_avoid_radius`: Navigation obstacle avoidance radius (default: 0.2)
- `box_threshold`: GroundingDINO detection threshold (default: 0.1)
- `text_threshold`: GroundingDINO text matching threshold (default: 0.1)

### Important Paths
- **Host**: `DovSG/data_example/`, `DovSG/checkpoints/`
- **Container**: `/app/data_example/`, `/app/checkpoints/`

Data artifacts for each scene (e.g., "room1"):
- `data_example/room1/rgb/`, `data_example/room1/depth/`: RGB-D images
- `data_example/room1/poses_droidslam/`: Camera poses from DROID-SLAM
- `data_example/room1/memory/`: Cached semantic detections and instances
- `data_example/room1/ace_models/`: Trained ACE relocalization models

## Data Setup

Model checkpoints (~11GB):
```bash
cd docker/
./scripts/download
```

Sample data (~23GB) - manual download from [Google Drive](https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing), extract to `DovSG/data_example/room1/`

## Dependencies

Third-party code (required before building):
```bash
cd docker/
./scripts/download_third_party.sh
```

This downloads:
- DROID-SLAM (pose estimation)
- ACE (relocalization)
- GroundingDINO (object detection)
- SegmentAnything2 (segmentation)

## Real Robot Integration

ROS integration scripts in [DovSG/hardcode/](DovSG/hardcode/) support:
- UFACTORY xARM6 robotic arm
- Agilex Ranger Mini 3 mobile base
- RealSense D455 camera