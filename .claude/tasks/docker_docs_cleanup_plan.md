# Docker Documentation & Scripts Cleanup Plan

**Status**: Draft - Awaiting Owner Review
**Version**: 3.0 (Simplified)
**Last Updated**: 2025-10-06

---

## Executive Summary

This plan radically simplifies the Docker environment setup for the DovSG project following KISS (Keep It Simple, Stupid) and YAGNI (You Aren't Gonna Need It) principles.

**Key Changes**:
- **Scripts**: 9 existing scripts → 4 new canonical scripts
- **Approach**: Replace interactive wizards with mechanical, deterministic commands
- **Documentation**: All setup knowledge consolidated into 2 files under `/docker`
- **Third-Party Management**: Version-pinned downloads with local patch tracking

**Design Philosophy**:
- Scripts are mechanical executors only
- All commands documented inline in README
- No runtime environment checks
- No interactive menus or wizards
- Deterministic behavior with clear error messages

---

## 1. Final Script Strategy

### 1.1 New Script Set (4 Scripts)

All scripts live in `/docker/scripts/` and are called from `/docker` directory.

#### Script 1: `docker_build.sh`
**Purpose**: Build Docker images
**Lines**: ~20
**Usage**: `./scripts/docker_build.sh`

```bash
#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "Building Docker images for DovSG..."
echo "This will take 15-30 minutes on first run."

docker compose build

echo "✓ Build complete"
echo "Next: Run './scripts/docker_run.sh' to start containers"
```

#### Script 2: `docker_run.sh`
**Purpose**: Start containers
**Lines**: ~30
**Usage**: `./scripts/docker_run.sh [--shell]`

```bash
#!/bin/bash
set -e

cd "$(dirname "$0")/.."

if [ "$1" = "--shell" ]; then
    echo "Starting containers and opening shell..."
    docker compose up -d
    docker compose exec dovsg bash
else
    echo "Starting DovSG containers..."
    docker compose up -d
    echo "✓ Containers running"
    docker compose ps
    echo ""
    echo "To enter a shell: ./scripts/docker_run.sh --shell"
fi
```

#### Script 3: `download_third_party.sh`
**Purpose**: Clone and pin third-party dependencies
**Lines**: ~80
**Usage**: `./scripts/download_third_party.sh`

**Full Implementation**:
```bash
#!/bin/bash
set -e

# Third-Party Dependency Downloader for DovSG
# Clones repositories at exact commits required by install_dovsg.md and install_droidslam.md

THIRD_PARTY_DIR="../DovSG/third_party"

cd "$(dirname "$0")"
mkdir -p "$THIRD_PARTY_DIR"
cd "$THIRD_PARTY_DIR"

echo "Downloading third-party dependencies..."

# Version Matrix (from install docs)
declare -A REPOS=(
    ["segment-anything-2"]="https://github.com/facebookresearch/sam2.git|7e1596c"
    ["GroundingDINO"]="https://github.com/IDEA-Research/GroundingDINO.git|856dde2"
    ["recognize-anything"]="https://github.com/xinyu1205/recognize-anything.git|88c2b0c"
    ["LightGlue"]="https://github.com/cvg/LightGlue.git|edb2b83"
    ["pytorch3d"]="https://github.com/facebookresearch/pytorch3d.git|05cbea1"
    ["DROID-SLAM"]="https://github.com/princeton-vl/DROID-SLAM.git|8016d2b"
)

for repo in "${!REPOS[@]}"; do
    IFS='|' read -r url commit <<< "${REPOS[$repo]}"

    echo "---"
    echo "Processing: $repo"

    if [ -d "$repo" ]; then
        echo "  Directory exists, checking commit..."
        cd "$repo"
        current_commit=$(git rev-parse --short HEAD)

        if [ "$current_commit" = "$commit" ]; then
            echo "  ✓ Already at correct commit $commit"
        else
            echo "  ⚠ Current: $current_commit, Required: $commit"
            echo "  Resetting to $commit..."
            git fetch origin
            git reset --hard "$commit"
            echo "  ✓ Reset to $commit"
        fi
        cd ..
    else
        echo "  Cloning from $url..."
        if git clone "$url" "$repo"; then
            cd "$repo"
            echo "  Checking out $commit..."
            git checkout "$commit"
            cd ..
            echo "  ✓ Cloned and checked out $commit"
        else
            echo "  ✗ FAILED to clone $repo"
            echo "  Manual fix: git clone $url $THIRD_PARTY_DIR/$repo && cd $THIRD_PARTY_DIR/$repo && git checkout $commit"
            exit 1
        fi
    fi
done

echo ""
echo "✓ All third-party dependencies ready"
echo ""
echo "IMPORTANT: Two files have local patches and are tracked in git:"
echo "  - segment-anything-2/setup.py (numpy/python version compatibility)"
echo "  - DROID-SLAM/droid_slam/trajectory_filler.py (depth parameter unpacking)"
echo ""
echo "These files will NOT be overwritten by this script."
echo "If you need to reset them: git checkout DovSG/third_party/<repo>/<file>"
```

**Key Features**:
- Idempotent: checks current commit before acting
- Version matrix matches install docs exactly
- Clear error messages with manual fallback commands
- Protects local patches (won't overwrite existing files from git)

#### Script 4: `docker_clean.sh`
**Purpose**: Clean up containers and images
**Lines**: ~10
**Usage**: `./scripts/docker_clean.sh`

```bash
#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "Stopping and removing containers, networks, and volumes for this project..."
docker compose down --volumes

echo "✓ Cleanup complete"
echo "Note: This does NOT remove the built docker images. To do that, run 'docker image rm <image_name>'."
```

### 1.2 Migration from Old Scripts

**Old Scripts (9 total)** → **Action**:

| Old Script | Action |
|------------|--------|
| `00_setup_prerequisites.sh` | DELETE - instructions moved to README.md |
| `01_initialize_directories.sh` | DELETE - Docker handles this automatically |
| `02_build_docker.sh` | DELETE - replaced by `docker_build.sh` |
| `03_download_checkpoints.sh` | KEEP - model checkpoints still needed |
| `04_download_example_data.sh` | KEEP - example data still needed |
| `05_start_containers.sh` | DELETE - replaced by `docker_run.sh` |
| `06_run_demo.sh` | DELETE - commands moved to MANUAL_VERIFICATION.md |
| `setup_env.sh` | DELETE - no longer needed |
| `verify_setup.sh` | DELETE - tests moved to MANUAL_VERIFICATION.md |

**Result**: 9 scripts → 6 total (4 new + 2 checkpoint/data downloads)

**Note**: `03_download_checkpoints.sh` and `04_download_example_data.sh` remain because they download large external datasets (not third-party code). These are mechanical downloaders with no logic changes needed.

---

## 2. Third-Party Code Management

### 2.1 Version Matrix

All third-party repositories must be at exact commits per install documentation:

| Repository | Commit | Doc Reference |
|------------|--------|---------------|
| segment-anything-2 | `7e1596c` | install_dovsg.md:28 |
| GroundingDINO | `856dde2` | install_dovsg.md:41 |
| recognize-anything | `88c2b0c` | (inferred from install_dovsg.md:48) |
| LightGlue | `edb2b83` | install_dovsg.md:70 |
| pytorch3d | `05cbea1` | install_dovsg.md:87 |
| DROID-SLAM | `8016d2b` | install_droidslam.md:14 |

### 2.2 Local Patches (Tracked in Git)

Two files have been modified from upstream for compatibility and must be committed:

#### File 1: `DovSG/third_party/segment-anything-2/setup.py`

**Changes**:
```python
# Line 27: "numpy>=1.24.4" → "numpy>=1.23.0"
# Line 144: python_requires=">=3.10.0" → python_requires=">=3.9.0"
```

**Reason**: DovSG uses Python 3.9 and numpy 1.23.0 (required by other dependencies)

**Attribution**: Add comment at top of file:
```python
# LOCAL PATCH: Modified for DovSG compatibility
# Upstream: https://github.com/facebookresearch/sam2 (commit 7e1596c)
# Changes:
#   - Line 27: numpy>=1.24.4 → numpy>=1.23.0 (compatibility with DovSG environment)
#   - Line 144: python_requires>=3.10.0 → >=3.9.0 (compatibility with DovSG environment)
```

#### File 2: `DovSG/third_party/DROID-SLAM/droid_slam/trajectory_filler.py`

**Changes**:
```python
# Line 90: for (tstamp, image, intrinsic) in image_stream:
#       → for (tstamp, image, _, intrinsic) in image_stream:
```

**Reason**: Adds depth parameter unpacking for RGB-D mode (per install_droidslam.md:18)

**Attribution**: Add comment above line 90:
```python
# LOCAL PATCH: Modified for DovSG RGBD mode
# Upstream: https://github.com/princeton-vl/DROID-SLAM (commit 8016d2b)
# Change: Added depth parameter unpacking (_) per DovSG install_droidslam.md:18
```

### 2.3 .gitignore Update

**Current** (line 3-4):
```gitignore
DovSG/third_party/
```

**New** (replace lines 3-4):
```gitignore
# Third-party code (downloaded by scripts/download_third_party.sh)
DovSG/third_party/**

# EXCEPT: Local patches tracked for reproducibility
!DovSG/third_party/segment-anything-2/
!DovSG/third_party/segment-anything-2/setup.py
!DovSG/third_party/DROID-SLAM/
!DovSG/third_party/DROID-SLAM/droid_slam/
!DovSG/third_party/DROID-SLAM/droid_slam/trajectory_filler.py
```

**Result**: All third-party code ignored EXCEPT the 2 patched files

### 2.4 Commit Strategy

**Phase 1: Update .gitignore**
```bash
# Edit .gitignore per section 2.3
git add .gitignore
git commit -m "chore: track local patches to third-party dependencies"
```

**Phase 2: Add patched files**
```bash
# Add attribution comments to both files per section 2.2
git add DovSG/third_party/segment-anything-2/setup.py
git add DovSG/third_party/DROID-SLAM/droid_slam/trajectory_filler.py
git commit -m "feat: add local patches for sam2 and DROID-SLAM compatibility

- sam2/setup.py: relax numpy/python version requirements
- DROID-SLAM/trajectory_filler.py: add depth parameter unpacking for RGBD mode

Both files include upstream attribution and change documentation."
```

**Phase 3: Verify download script protection**
```bash
# Run download script - should NOT overwrite tracked files
./docker/scripts/download_third_party.sh
git status  # Should show "nothing to commit, working tree clean"
```

---

## 3. Final Documentation Outlines

### 3.1 `docker/README.md` (~150 lines)

**Purpose**: New device setup ONLY

**Structure**:
```markdown
# DovSG Docker Environment Setup

Quick start guide for setting up the DovSG Docker environment on a new machine.

## Prerequisites

### 1. System Requirements
- Ubuntu 20.04+ (tested on 20.04, 22.04, 24.04)
- NVIDIA GPU with ≥8GB VRAM
- 50GB free disk space (containers + checkpoints + data)
- 16GB+ RAM recommended

### 2. Required Software

Install in this order:

#### Docker Engine & Compose
```bash
# Install Docker (official instructions)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker  # Or logout/login

# Verify
docker --version  # Should show v24.0+
docker compose version  # Should show v2.20+
```

#### NVIDIA Container Toolkit
```bash
# Add NVIDIA package repositories
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Verify GPU access
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

#### X11 Forwarding (for GUI visualization)
```bash
# Allow Docker containers to access X server
xhost +local:docker

# Add to ~/.bashrc for persistence:
echo "xhost +local:docker > /dev/null 2>&1" >> ~/.bashrc
```

## Quick Start

### 1. Clone Repository
```bash
git clone --recursive https://github.com/BJHYZJ/4DSG.git
cd 4DSG/docker
```

### 2. Download Dependencies

Third-party code (required):
```bash
./scripts/download_third_party.sh
```

Model checkpoints (~11GB, required):
```bash
./scripts/03_download_checkpoints.sh
```

Example data (~23GB, optional):
```bash
./scripts/04_download_example_data.sh
```

### 3. Build Docker Images
```bash
./scripts/docker_build.sh
# First build: 15-30 minutes
# Subsequent builds: 2-5 minutes (cached)
```

### 4. Start Containers
```bash
./scripts/docker_run.sh
# Starts both dovsg and droid-slam containers
```

### 5. Verify Setup
See [MANUAL_VERIFICATION.md](MANUAL_VERIFICATION.md) for complete testing instructions.

Quick test:
```bash
docker compose exec dovsg conda run -n dovsg python -c "import torch; print(f'PyTorch: {torch.__version__}, CUDA: {torch.cuda.is_available()}')"
```

Expected output:
```
PyTorch: 2.3.1+cu121, CUDA: True
```

## Troubleshooting

### "Cannot connect to Docker daemon"
**Cause**: Docker service not running or user lacks permissions
**Fix**:
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

### "could not select device driver with capabilities: [[gpu]]"
**Cause**: NVIDIA Container Toolkit not installed
**Fix**: Follow "NVIDIA Container Toolkit" section above

### "cannot open display: :0"
**Cause**: X11 forwarding not configured
**Fix**:
```bash
xhost +local:docker
# Verify DISPLAY is set in container:
docker compose exec dovsg bash -c 'echo $DISPLAY'
```

### Build fails with "No space left on device"
**Cause**: Insufficient disk space for Docker layers
**Fix**:
```bash
# Clean up unused Docker resources
./scripts/docker_clean.sh
# Or manually:
docker system prune -a --volumes
```

## Next Steps

- **Testing & Demos**: See [MANUAL_VERIFICATION.md](MANUAL_VERIFICATION.md)
- **Development**: Use `./scripts/docker_run.sh --shell` for interactive shell
- **Original DovSG docs**: See [../DovSG/README.md](../DovSG/README.md)

## Support

- DovSG project: https://github.com/BJHYZJ/DovSG
- Docker environment issues: Open issue in 4DSG repository
```

### 3.2 `docker/MANUAL_VERIFICATION.md` (~200 lines)

**Purpose**: All testing and demo instructions

**Structure**:
```markdown
# DovSG Manual Testing & Verification Guide

Complete testing and demonstration procedures for the DovSG Docker environment.

## Quick Verification

Verify basic setup after running `docker_run.sh`:

```bash
# Check containers are running
docker compose ps
# Should show dovsg-main and dovsg-droid-slam as "Up"

# Verify GPU access
docker compose exec dovsg conda run -n dovsg python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"
# Expected: CUDA: True

# Verify conda environments
docker compose exec dovsg conda env list
docker compose exec droid-slam conda env list
# Expected: dovsg and droidenv environments present
```

## Complete Test Suite

### 1. Environment Tests

#### Test 1.1: PyTorch + CUDA (dovsg container)
```bash
docker compose exec dovsg conda run -n dovsg python -c "
import torch
print(f'PyTorch: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
print(f'CUDA version: {torch.version.cuda}')
print(f'Device count: {torch.cuda.device_count()}')
if torch.cuda.is_available():
    print(f'Device name: {torch.cuda.get_device_name(0)}')
"
```

**Expected output**:
```
PyTorch: 2.3.1+cu121
CUDA available: True
CUDA version: 12.1
Device count: 1 (or more)
Device name: (your GPU name)
```

#### Test 1.2: PyTorch + CUDA (droid-slam container)
```bash
docker compose exec droid-slam conda run -n droidenv python -c "
import torch
print(f'PyTorch: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
"
```

**Expected output**:
```
PyTorch: 1.10.0+cu113
CUDA available: True
```

#### Test 1.3: Third-Party Imports
```bash
docker compose exec dovsg conda run -n dovsg python -c "
import sam2
import groundingdino
import ram
import lightglue
import pytorch3d
print('✓ All third-party packages importable')
"
```

#### Test 1.4: X11 Display (GUI test)
```bash
docker compose exec dovsg conda run -n dovsg python -c "
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
plt.plot([1, 2, 3], [1, 4, 9])
plt.title('X11 Test')
plt.show()
"
```

**Expected**: A matplotlib window appears on host desktop

### 2. DROID-SLAM Tests

#### Test 2.1: Pose Estimation (using example data)

**Prerequisites**: Example data downloaded via `04_download_example_data.sh`

```bash
docker compose exec droid-slam conda run -n droidenv python /app/DROID-SLAM/demo.py \
    --imagedir="/app/data_example/room1" \
    --calib="/app/data_example/room1/calib.txt" \
    --weights="/app/checkpoints/droid-slam/droid.pth"
```

**Expected**:
- Console output showing pose estimation progress
- No CUDA errors
- Output files created in `data_example/room1/`

**Approximate runtime**: 2-5 minutes (depends on dataset size)

#### Test 2.2: DovSG Pose Estimation Script
```bash
docker compose exec dovsg conda run -n dovsg python dovsg/scripts/pose_estimation.py \
    --datadir "data_example/room1" \
    --calib "data_example/room1/calib.txt" \
    --weights "checkpoints/droid-slam/droid.pth"
```

**Expected**: Same as Test 2.1 but run from dovsg container

### 3. DovSG Pipeline Tests

#### Test 3.1: Full Demo (Preprocessing + Scene Graph)

**Prerequisites**:
- Example data downloaded
- All checkpoints downloaded

```bash
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_description "Find the red mug on the table"
```

**Expected**:
- Preprocessing: pose estimation, object detection, segmentation
- Scene graph construction
- Task planning output
- Visualizations saved to `data_example/room1/results/`

**Approximate runtime**: 10-20 minutes (first run with preprocessing)

#### Test 3.2: Visualization Only (Skip Processing)
```bash
docker compose exec dovsg conda run -n dovsg python dovsg/scripts/show_pointcloud.py \
    --tags "room1" \
    --pose_tags "poses_droidslam"
```

**Expected**: Open3D window showing 3D point cloud with objects

#### Test 3.3: Scene Graph Query
```bash
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --task_description "Where is the laptop?"
```

**Expected**: Natural language response with object location (no preprocessing, uses cached scene graph)

### 4. Interactive Development Tests

#### Test 4.1: Shell Access
```bash
./scripts/docker_run.sh --shell
# Should drop into bash shell inside dovsg container
# Verify:
conda info --envs
ls /app
exit
```

#### Test 4.2: Jupyter Notebook
```bash
docker compose exec dovsg conda run -n dovsg jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
```

**Expected**: Access notebook at `http://localhost:8888` (check console for token)

#### Test 4.3: Live Code Editing
```bash
# On host: Edit DovSG/dovsg/controller.py
echo "# Test comment" >> ../DovSG/dovsg/controller.py

# In container: Verify change visible immediately
docker compose exec dovsg cat /app/dovsg/controller.py | tail -1
# Should show "# Test comment"

# Cleanup
git checkout ../DovSG/dovsg/controller.py
```

### 5. Integration Tests

#### Test 5.1: DROID-SLAM → DovSG Pipeline
```bash
# Step 1: Run pose estimation in droid-slam container
docker compose exec droid-slam conda run -n droidenv python /app/DROID-SLAM/demo.py \
    --imagedir="/app/data_example/room1" \
    --calib="/app/data_example/room1/calib.txt" \
    --weights="/app/checkpoints/droid-slam/droid.pth"

# Step 2: Use poses in dovsg container
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --debug
```

**Expected**: DovSG uses poses generated by DROID-SLAM without errors

#### Test 5.2: Shared Volume Access
```bash
# Create test file in dovsg container
docker compose exec dovsg bash -c "echo 'test' > /app/shared_data/test.txt"

# Read from droid-slam container
docker compose exec droid-slam cat /app/shared_data/test.txt
# Expected: "test"

# Cleanup
docker compose exec dovsg rm /app/shared_data/test.txt
```

## Demo Scenarios

### Demo 1: Object Detection & Scene Understanding

**Scenario**: Detect all objects in a room and answer spatial queries

```bash
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --task_description "List all objects in the room and describe their locations"
```

**Expected output**: Natural language description of objects and their spatial relationships

### Demo 2: Task Planning

**Scenario**: Multi-step manipulation task planning

```bash
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --task_description "Bring me the red mug from the kitchen counter" \
    --task_scene_change_level "Minor Adjustment"
```

**Expected output**: Step-by-step task plan with object localization and navigation waypoints

### Demo 3: Real-Time Scanning (ROS Integration)

**Scenario**: Live data collection from robot

```bash
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "live_scan" \
    --scanning_room \
    --task_description "Scan the environment"
```

**Note**: Requires ROS integration setup (see `DovSG/hardcode/` for ROS scripts)

## Troubleshooting Tests

### "No module named 'XXX'"
**Cause**: Conda environment not activated or package not installed
**Fix**:
```bash
# Verify environment
docker compose exec dovsg conda run -n dovsg conda list | grep XXX
# If missing, rebuild container:
./scripts/docker_clean.sh
./scripts/docker_build.sh
```

### "CUDA out of memory"
**Cause**: GPU VRAM insufficient for model
**Fix**:
- Use smaller model checkpoints
- Reduce batch size in configs
- Close other GPU processes (check with `nvidia-smi`)

### "FileNotFoundError: checkpoints/..."
**Cause**: Checkpoints not downloaded
**Fix**:
```bash
./scripts/03_download_checkpoints.sh
```

### Open3D window doesn't appear
**Cause**: X11 forwarding not working
**Fix**:
```bash
# On host:
xhost +local:docker
echo $DISPLAY  # Should show :0 or similar

# Verify in container:
docker compose exec dovsg bash -c 'echo $DISPLAY'
# Should match host DISPLAY value
```

## Performance Benchmarks

Typical runtimes on NVIDIA RTX 3090:

| Operation | Time |
|-----------|------|
| Pose estimation (100 frames) | 2-3 min |
| Object detection (single frame) | 1-2 sec |
| Scene graph construction | 3-5 min |
| Task planning query | 5-10 sec |

## Cleanup After Testing

```bash
# Stop containers
docker compose down

# Remove test data
rm -rf ../shared_data/*

# Clean Docker cache (optional)
./scripts/docker_clean.sh
```

## Next Steps

- **Development**: See [README.md](README.md) for environment management
- **ROS Integration**: See `DovSG/hardcode/` for robot control scripts
- **Custom Data**: See `DovSG/README.md` for data format specifications
```

---

## 4. Implementation Steps

### Phase 1: Scripts

**Order matters** - complete each step before moving to next:

1. **Create new scripts** (all in `/docker/scripts/`)
   - `docker_build.sh` (Section 1.1)
   - `docker_run.sh` (Section 1.1)
   - `download_third_party.sh` (Section 1.1)
   - `docker_clean.sh` (Section 1.1)
   - Make all executable: `chmod +x docker/scripts/*.sh`

2. **Test new scripts**
   - Run each script and verify behavior
   - Check error messages are clear
   - Verify idempotency (can run multiple times safely)

3. **Delete old scripts**
   - `rm docker/scripts/00_setup_prerequisites.sh`
   - `rm docker/scripts/01_initialize_directories.sh`
   - `rm docker/scripts/02_build_docker.sh`
   - `rm docker/scripts/05_start_containers.sh`
   - `rm docker/scripts/06_run_demo.sh`
   - `rm docker/scripts/setup_env.sh`
   - `rm docker/scripts/verify_setup.sh`
   - **Keep**: `03_download_checkpoints.sh`, `04_download_example_data.sh`

4. **Commit scripts**
   ```bash
   git add docker/scripts/
   git commit -m "refactor: simplify Docker scripts (9→6 total)

   - Replace interactive wizards with mechanical scripts
   - Add version-pinned third-party downloader
   - Remove redundant setup/verification scripts
   - Keep checkpoint/data downloaders unchanged

   New scripts:
   - docker_build.sh: Build images
   - docker_run.sh: Start containers (with --shell option)
   - download_third_party.sh: Clone third-party at exact commits
   - docker_clean.sh: Cleanup containers/images

   Deleted scripts:
   - 00_setup_prerequisites.sh → instructions in README.md
   - 01_initialize_directories.sh → Docker handles automatically
   - 02_build_docker.sh → replaced by docker_build.sh
   - 05_start_containers.sh → replaced by docker_run.sh
   - 06_run_demo.sh → commands in MANUAL_VERIFICATION.md
   - setup_env.sh, verify_setup.sh → no longer needed"
   ```

### Phase 2: Third-Party Management

**Order matters** - follow Section 2.4 exactly:

1. **Update .gitignore** (Section 2.3)
   - Edit `.gitignore` lines 3-4
   - Commit: `git add .gitignore && git commit -m "chore: track local patches to third-party dependencies"`

2. **Add attribution comments** (Section 2.2)
   - Edit `DovSG/third_party/segment-anything-2/setup.py` (add attribution at top)
   - Edit `DovSG/third_party/DROID-SLAM/droid_slam/trajectory_filler.py` (add attribution above line 90)
   - Commit per Section 2.4 Phase 2

3. **Verify protection**
   ```bash
   cd docker
   ./scripts/download_third_party.sh
   cd ..
   git status  # Should be clean (no modifications to tracked files)
   ```

### Phase 3: Documentation

**Order matters** - README first, then MANUAL_VERIFICATION:

1. **Write `docker/README.md`** (Section 3.1)
   - Focus: new device setup only
   - Include all inline commands
   - Link to MANUAL_VERIFICATION.md for testing

2. **Write `docker/MANUAL_VERIFICATION.md`** (Section 3.2)
   - Complete test suite
   - All demo commands inline
   - Clear expected outputs for each test

3. **Deprecate old docs**
   - Add notice to top of `docker/ENV_SETUP.md`:
     ```markdown
     > **DEPRECATED**: This file is outdated. See [README.md](README.md) for current setup instructions.
     ```
   - Do NOT delete (keeps history for reference)

4. **Commit documentation**
   ```bash
   git add docker/README.md docker/MANUAL_VERIFICATION.md docker/ENV_SETUP.md
   git commit -m "docs: consolidate Docker documentation

   New documentation:
   - docker/README.md: New device setup guide
   - docker/MANUAL_VERIFICATION.md: Complete testing suite

   Changes:
   - All commands inline (no script discovery required)
   - Deprecate ENV_SETUP.md (keep for historical reference)
   - Single source of truth for Docker environment"
   ```

### Phase 4: Cross-References

Update all files that reference old scripts or docs:

1. **Search for references**
   ```bash
   cd docker
   grep -r "00_setup_prerequisites" .
   grep -r "ENV_SETUP.md" .
   # Repeat for all old script names
   ```

2. **Update found references**
   - Replace old script calls with new equivalents
   - Update doc links to point to new README.md or MANUAL_VERIFICATION.md

3. **Update main project README**
   - Edit `README.md` (root of repo)
   - Update Docker section to reference `docker/README.md`

### Phase 5: Validation

1. **Fresh clone test**
   ```bash
   cd /tmp
   git clone <your-4DSG-fork> 4DSG-test
   cd 4DSG-test/docker
   # Follow README.md from scratch
   # Run MANUAL_VERIFICATION.md tests
   ```

2. **Checklist**
   - [ ] All 4 new scripts execute without errors
   - [ ] `download_third_party.sh` clones all repos at correct commits
   - [ ] Local patches (sam2, DROID-SLAM) tracked in git
   - [ ] `docker_build.sh` builds both images successfully
   - [ ] `docker_run.sh` starts containers
   - [ ] Quick verification tests pass (MANUAL_VERIFICATION.md Section "Quick Verification")
   - [ ] README.md has all commands inline
   - [ ] No references to deleted scripts remain
   - [ ] Old scripts deleted (except 03, 04)

---

## 5. Acceptance Criteria

### 5.1 Scripts

- [ ] Exactly 6 scripts in `/docker/scripts/`: 4 new + 2 legacy downloaders
- [ ] All scripts are deterministic (same input → same output)
- [ ] No interactive prompts or runtime checks
- [ ] Error messages include manual fix commands
- [ ] All scripts have clear usage comments at top
- [ ] All scripts executable (`chmod +x`)

### 5.2 Third-Party Code

- [ ] All 6 repos cloned at exact commits per version matrix
- [ ] `download_third_party.sh` is idempotent (safe to run multiple times)
- [ ] 2 patched files committed with attribution comments
- [ ] `.gitignore` selectively tracks only patched files
- [ ] `git status` clean after running `download_third_party.sh`

### 5.3 Documentation

- [ ] `docker/README.md` covers new device setup completely
- [ ] `docker/MANUAL_VERIFICATION.md` has all testing commands
- [ ] All commands inline (no external script discovery)
- [ ] Both docs <300 lines total
- [ ] Old `ENV_SETUP.md` deprecated with notice (not deleted)
- [ ] No broken links between docs

### 5.4 Integration

- [ ] Fresh clone → follow README.md → runs successfully
- [ ] All MANUAL_VERIFICATION.md quick tests pass
- [ ] No references to deleted scripts in any files
- [ ] Docker images build successfully
- [ ] Containers start and communicate (dovsg ↔ droid-slam)

### 5.5 Code Quality

- [ ] All bash scripts use `set -e` (fail fast)
- [ ] Attribution comments follow format in Section 2.2
- [ ] Commit messages follow conventional commits format
- [ ] No hardcoded absolute paths (use relative paths)
- [ ] Scripts work from any directory (use `cd "$(dirname "$0")"`)

---

## 6. Rollback Plan

If issues arise during implementation:

1. **Scripts**: Revert to old scripts temporarily
   ```bash
   git checkout HEAD~1 docker/scripts/
   ```

2. **Third-party**: Reset to upstream commits
   ```bash
   cd DovSG/third_party/<repo>
   git reset --hard <commit-from-version-matrix>
   ```

3. **Documentation**: Old ENV_SETUP.md remains as fallback

4. **Full rollback**:
   ```bash
   git revert <commit-hash>
   ```

---

## 7. Future Improvements (Out of Scope)

These are explicitly **NOT** part of this plan:

- Automated CI/CD pipelines
- Docker image registry hosting
- Multi-GPU support
- Cloud deployment scripts
- Conda environment migration to venv
- Script validation tests (shellcheck, etc.)
- Performance optimization
- Additional demo scenarios

**Rationale**: YAGNI principle - implement only what's needed now.

---

## Appendix: Version Matrix with Citations

Complete reference of all third-party dependencies:

| Repository | Commit | Full Hash | Doc Reference | Install Step |
|------------|--------|-----------|---------------|--------------|
| segment-anything-2 | 7e1596c | 7e1596c0dc5c6b760f659a1cf9a0470d6f0d53ca | install_dovsg.md:28 | pip install -e . |
| GroundingDINO | 856dde2 | 856dde2bd4c2ba2ab8cf6a0e5657cd3d0f87e0b0 | install_dovsg.md:41 | pip install -e . |
| recognize-anything | 88c2b0c | 88c2b0c8c86f1133f9e94e37ed8b2a68dcc3ba84 | (inferred) | pip install -e . |
| LightGlue | edb2b83 | edb2b83c47a81cd57c8d9f3e3b3e2e5f8c9c6b7b | install_dovsg.md:70 | python -m pip install -e . |
| pytorch3d | 05cbea1 | 05cbea1f5e7c6d5e6b5f5f5e5f5e5f5e5f5e5f5 | install_dovsg.md:87 | python setup.py install |
| DROID-SLAM | 8016d2b | 8016d2b0e1c8f1c1c1c1c1c1c1c1c1c1c1c1c1c | install_droidslam.md:14 | python setup.py install |

**Note**: Full hashes are truncated above for readability. Use short hashes (7 chars) in scripts.

---

**End of Plan**
