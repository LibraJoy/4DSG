# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Principles
When received user's require about editing code, follow these principles:

### KISS (Keep It Simple, Stupid)
- Write code straightforward, provide uncomplicated solutions
- avoids over engineering and unnecessary complexity
- Results in more readable and maintainable code

### YAGNI(You Aren't Gonna Need It)
- Prevents adding speculative features
- Focuses on implementing only wht's currently needed
- Reduces code bloat and maintenance overhead

### SOLID Principles
- Single Responsibility Principle
- Open-Closed Principle
- Liskov Substitution Principle
- Interface Segregation Principle
- Dependency Inversion Principle

### Remove file carefully
- Never remove file except from this project, like when remove docker image, don't do command like *docker system prune -a*.

### Keep the content generate style serious and concise
- Never generate content with icons or emoticons

### 

## Plan & Review

### Before starting any work
- Always in plan mode to make a plan
- After get the plan, make sure you write a plan to .claude/tasks/TASK_NAME.md.
- The pln should be a detailed implementation plan and the reasoning behind them, as well as tasks broken down.
- If the task requrie external knowledge or meratin package, also reserach to get leaset knowledge, also reserch to get latest knowledge (Use Task tools for research)
- Don't over plan it, always think MVP.
- Once you write the plan, firstly ask me to review it, Do not continuse until I approve the plan.

### While implementing
- You should undate the plan as you work.
- After you complete tasks in the plan, you should update and append detailed descriptions of the changes you made, so following tasks can be easily hand over to other engineers

## Project Overview

This repository provides a complete Docker-based environment for **DovSG (Dense Open-Vocabulary 3D Scene Graphs)** - a system that constructs dynamic 3D scene graphs for long-term language-guided mobile manipulation tasks. The project combines the original DovSG implementation with a unified Docker environment that works across different Ubuntu versions and hardware configurations.

## Repository Structure

```
4DSG/
├── DovSG/                      # Original DovSG project
│   ├── dovsg/                  # Core DovSG Python package
│   │   ├── controller.py       # Main controller orchestrating the pipeline
│   │   ├── scripts/            # Utility scripts (pose estimation, visualization, etc.)
│   │   └── modules/            # Core modules (detection, navigation, etc.)
│   ├── demo.py                 # Main entry point for DovSG demos
│   ├── setup.py               # Python package setup
│   ├── checkpoints/           # Model checkpoints (large files, downloaded separately)
│   ├── data_example/          # Sample data (downloaded separately)
│   └── docs/                  # Installation and setup documentation
├── docker/                    # Docker environment setup
│   ├── docker-compose.yml     # Multi-service Docker configuration
│   ├── dockerfiles/           # Container build definitions
│   └── scripts/               # Setup and management scripts
└── shared_data/              # Runtime data sharing between containers
```

## Core Architecture

DovSG pipeline consists of these key components:

1. **Data Collection & Pose Estimation**: Uses DROID-SLAM for camera pose estimation from RGB-D data
2. **3D Scene Graph Construction**: Leverages VLMs to represent objects as nodes with spatial relationships
3. **Relocalization**: Uses ACE (pose estimation) and LightGlue features for camera relocalization
4. **Task Planning**: LLM-based task decomposition and execution
5. **Dynamic Updates**: Continuous scene graph updates during robot operation

The main `Controller` class in `DovSG/dovsg/controller.py` orchestrates this entire pipeline.

## Development Commands

### Docker Environment Management

All commands should be run from the `docker/` directory:

### Running DovSG

```bash
# Main demo (from docker/ directory)
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_description "Your task description"

# Interactive shell for development
docker compose exec dovsg bash
# Inside container:
conda run -n dovsg python demo.py --help
```

### DROID-SLAM Pose Estimation

```bash
# Run pose estimation
docker compose exec droid-slam conda run -n droidenv python /app/DROID-SLAM/demo.py \
    --imagedir="/app/data_example/room1" \
    --calib="/app/data_example/room1/calib.txt" \
    --weights="/app/checkpoints/droid-slam/droid.pth"

# DovSG pose estimation script
docker compose exec dovsg conda run -n dovsg python dovsg/scripts/pose_estimation.py \
    --datadir "data_example/room1" \
    --calib "data_example/room1/calib.txt" \
    --weights "checkpoints/droid-slam/droid.pth"
```

### Visualization

```bash
# Visualize point clouds
docker compose exec dovsg conda run -n dovsg python dovsg/scripts/show_pointcloud.py \
    --tags "room1" \
    --pose_tags "poses_droidslam"
```

## Docker Services

- **dovsg**: Main DovSG environment (CUDA 12.1, PyTorch 2.3, Python 3.9)
- **droid-slam**: DROID-SLAM environment (CUDA 11.8, PyTorch 1.10, Python 3.9)

Both services share data through mounted volumes for checkpoints, data, and results.

## Data Requirements

### Required Downloads (not in Git due to size):

1. **Model Checkpoints (~11GB)**: Downloaded automatically via `./scripts/03_download_checkpoints.sh`
2. **Sample Data (~23GB)**: Manual download from [Google Drive](https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing)
   - Extract to: `DovSG/data_example/room1/`

## Development Workflow

1. **Code Changes**: Edit files in `DovSG/` (git tracked)
2. **Testing**: Use Docker containers for testing (no rebuild needed for Python code changes)
3. **Shell Access**: Use `docker compose exec dovsg bash` for interactive development
4. **Conda Environments**: Use `conda run -n dovsg` for single commands, or activate manually in shell

## Key Parameters & Configuration

### Demo.py Arguments:
- `--tags`: Scene identifier (e.g., "room1")
- `--preprocess`: Run pose estimation and preprocessing steps
- `--debug`: Enable debug output
- `--scanning_room`: Data collection mode (real robot)
- `--task_description`: Natural language task description
- `--task_scene_change_level`: Scene change level ("Minor Adjustment", etc.)

### Important Paths:
- Data: `/app/data_example/` (in containers)
- Checkpoints: `/app/checkpoints/` (in containers)
- Code: `/app/dovsg/` (in containers)


ROS integration scripts are available in `DovSG/hardcode/` for robot control.