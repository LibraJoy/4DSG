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

### Open an interactive shell

```bash
# Attach to the dovsg container with the environment ready
docker compose exec -it dovsg bash

# Inside the shell (examples)
which python          # should point to /opt/conda/envs/dovsg/bin/python
python -V             # confirms Python 3.9.x
python -c "import sys; print(sys.executable)"  # double-check active interpreter

# Run the demo with real-time logs
python -u demo.py --tags "room1" --skip_task_planning

exit                  # leave the shell when finished
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
# Basic X11 test
docker exec -it dovsg-main bash -c "echo \$DISPLAY && xeyes"
```

**Expected**: `xeyes` window appears (eyes follow mouse cursor)

#### Test 1.5: OpenGL Support
```bash
# Test OpenGL direct rendering
docker exec -it dovsg-main glxinfo | grep "direct rendering"

# Test with simple OpenGL demo
docker exec -it dovsg-main glxgears
```

**Expected**:
- "direct rendering: Yes"
- Rotating gears window with FPS counter
- Close with Ctrl+C

#### Test 1.6: Open3D GUI
```bash
docker compose exec dovsg conda run -n dovsg python -c "
import open3d as o3d
print('Testing Open3D GUI...')
mesh = o3d.geometry.TriangleMesh.create_coordinate_frame(size=1.0)
o3d.visualization.draw_geometries([mesh])
"
```

**Expected**: 3D coordinate frame window (interactive: drag to rotate, wheel to zoom)

### 2. DROID-SLAM Tests

#### Test 2.1: Pose Estimation (using example data)

**Prerequisites**: Example data downloaded

```bash
docker compose exec droid-slam conda run -n droidenv python dovsg/scripts/pose_estimation.py \
    --datadir="data_example/room1" \
    --calib="data_example/room1/calib.txt" \
    --weights="checkpoints/droid-slam/droid.pth" \
    --t0 0 \
    --stride 1 \
    --buffer 2048
```

**Expected**:
- Console output showing "Pose Estimation" progress bar
- Global BA (Bundle Adjustment) iterations output
- "Result Pose Number is XXX" message at the end
- No CUDA errors
- Output files created in `data_example/room1/poses_droidslam/`


**Note**: This test runs in the `droid-slam` container which has CUDA 11.8 + PyTorch 1.10, required for DROID-SLAM compatibility. The PYTHONPATH is set in the Dockerfile to `/app/DROID-SLAM/droid_slam` so Python can find the `droid` module.

### 3. DovSG Pipeline Tests

#### Test 3.1: Full Demo (Preprocessing + Scene Graph)

**Prerequisites**:
- Example data downloaded
- All checkpoints downloaded

**Artifact Structure** (created/required):
```
data_example/room1/
├── poses_droidslam/        # Camera poses (created by --preprocess)
├── memory/                 # View dataset cache (created)
├── ace/                    # ACE relocalization model (created)
├── semantic_memory/        # Object detection results (created)
├── instances/              # Instance segmentation (created)
└── instance_scene_graph.pkl # 3DSG data structure (created)
```

```bash
docker compose exec dovsg python -u demo.py --tags "room1" --preprocess --debug --skip_task_planning
```

*3DSG-only shortcut:* when you only need scene-graph generation/visualization (no relocalization), add `--skip_ace --skip_lightglue --semantic_device cpu` to skip ACE/LightGlue and run semantic tagging on CPU (avoids GPU OOM at the cost of slower tagging).

#### Interactive 3DSG Viewer Controls

When the main 3DSG viewer window appears (final step of Test 3.1):

**Keyboard Controls**:
- **B** - Toggle background point cloud visibility
- **C** - Color objects by semantic class (red=objects, green=surfaces)
- **R** - Color objects by RGB appearance (natural colors)
- **A** - Color by CLIP feature similarity (changed from 'F' on 2025-01-26)
- **G** - Toggle scene graph relationship lines (spatial edges between objects)
- **I** - Color by instance ID (unique color per detected object)
- **O** - Toggle 3D bounding boxes around objects
- **V** - Save current view parameters (camera position, zoom)

**Mouse Controls**:
- **Left drag** - Rotate camera view
- **Right drag** - Pan camera position
- **Scroll wheel** - Zoom in/out

#### Test 3.2: 3DSG-Only Pipeline (Skip Preprocessing)

**Prerequisites**: Test 3.1 must be run first to generate required artifacts

**Purpose**: Fast execution of 3DSG construction without re-running heavy preprocessing

```bash
# Option 1: Using dedicated script (if available)
./scripts/run_3dsg_only.sh room1

# Option 2: Direct command (skips --preprocess)
docker compose exec dovsg python -u demo.py \
  --tags room1 \
  --preprocess \
  --debug \
  --skip_task_planning \
  --skip_ace \
  --skip_lightglue
```

*3DSG-only shortcut:* add `--semantic_device cpu` if GPU memory is tight.

**Common Errors**:
- `FileNotFoundError: poses_droidslam/` → Run Test 3.1 with `--preprocess` first
- `FileNotFoundError: memory/` → Missing preprocessed view dataset

#### Test 3.3: Visualization Only
```bash
docker compose exec dovsg conda run -n dovsg python dovsg/scripts/show_pointcloud.py \
    --tags "room1" \
    --pose_tags "poses_droidslam"
```

**Expected**: Open3D window showing 3D point cloud with objects

#### Test 3.4: Scene Graph Query
```bash
docker compose exec dovsg python -u demo.py --tags "room1" --task_description "Where is the laptop?"
```

**Expected**: Natural language response with object location

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

### 5. Data Collection with RealSense Camera

DovSG supports two data collection workflows:

#### Option 1: Two-Stage ROS Bag Workflow (Recommended)

**Stage 1 - Record ROS Bag:**
```bash
cd docker/
./scripts/record_rosbag.sh
```

This launches the RealSense camera node, verifies RGB-D topics are publishing, and records to `/app/rosbags/recording_YYYYMMDD_HHMMSS.bag`.

**Stage 2 - Process Bag to DovSG Format:**
```bash
# Process bag file (output auto-generated in data_example/)
docker compose exec dovsg python record.py --from-bag data_example/rosbags/recording_*.bag

# Specify custom output directory
docker compose exec dovsg python record.py \
    --from-bag data_example/rosbags/recording_20251112_154403.bag \
    --output-dir data_example/room2
```

**Why ROS Bags?**
- Decouple recording from processing (lightweight vs heavy ML environment)
- Reprocess data multiple times without re-recording
- Standard format for dataset sharing

#### Option 2: Live Camera Recording (Legacy)
Direct recording from RealSense D435i:
```bash
docker compose exec dovsg python dovsg/scripts/realsense_recorder.py
```

**Note**: Update camera serial number in `DovSG/record_rosbag.py` (default: "215222073770")
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

### "No protocol specified" or "authorization required" (Wayland)
**Cause**: Wayland display server not allowing X11 forwarding
**Fix**:
```bash
# Force XWayland
export WAYLAND_DISPLAY=""
xhost +SI:localuser:root

# Or temporarily disable access control:
xhost +
```

### GUI windows appear but are blank/corrupted
**Cause**: Software rendering instead of GPU acceleration
**Fix**:
```bash
# Check graphics drivers
docker exec -it dovsg-main glxinfo | grep "OpenGL renderer"
# Should show your GPU, not "llvmpipe" or "software"

# Test with simple graphics
docker exec -it dovsg-main xlogo
```

### Open3D windows don't respond to keyboard
**Cause**: Window not focused
**Fix**:
1. Click on the Open3D window to ensure focus
2. Try pressing keys with window active
3. Verify keyboard input is working:
```bash
docker exec -it dovsg-main conda run -n dovsg python -c "
import open3d as o3d
vis = o3d.visualization.VisualizerWithKeyCallback()
vis.create_window()
print('Press keys for testing (Q to quit)')
def key_callback(vis):
    print('Key pressed!')
    return False
vis.register_key_callback(ord('Q'), key_callback)
vis.run()
"
```
