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
docker compose exec droid-slam conda run -n droidenv python /app/DROID-SLAM/demo.py \
    --imagedir="/app/data_example/room1" \
    --calib="/app/data_example/room1/calib.txt" \
    --weights="/app/checkpoints/droid-slam/droid.pth"
```

**Expected**:
- Console output showing pose estimation progress
- No CUDA errors
- Output files created in `data_example/room1/`

**Approximate runtime**: 2-5 minutes

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

*3DSG-only shortcut:* when you only need scene-graph generation/visualization (no relocalization), add `--skip_ace --skip_lightglue` to skip the ACE training and LightGlue feature extraction stages. These components are used later for relocalization/path-planning and are not required for the viewer.

**Expected GUI Windows** (during execution):
1. DROID-SLAM point cloud visualization
2. View dataset point cloud
3. Interactive 3DSG viewer (1280x720) - final output

**Expected Terminal Output**:
- Real-time logging (not buffered)
- Preprocessing steps: pose estimation, object detection, segmentation
- Scene graph construction progress
- Message indicating task planning is skipped

**Approximate runtime**: 10-20 minutes (first run); 5-10 min (subsequent with cached artifacts)

**GPU Memory**: ~5-7GB VRAM used during execution

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

**Testing Procedure**:
1. Wait for 3DSG viewer window to appear
2. Click on window to ensure focus
3. Test each keyboard control (press keys while focused)
4. Verify visual changes occur for each key
5. Test mouse controls (rotation, pan, zoom)
6. All interactions should be smooth and responsive

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

*3DSG-only shortcut:* add `--skip_lightglue` if LightGlue features are not needed.

**Expected**:
- Skips pose estimation and preprocessing steps
- Uses cached artifacts from `data_example/room1/`
- Runs semantic memory, instance segmentation, and 3DSG construction
- Opens interactive 3DSG viewer
- **Runtime**: 5-10 minutes (vs 10-20 with --preprocess)

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

#### Test 4.2: Live Code Editing
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
docker compose exec dovsg python -u demo.py --tags "room1" --debug --skip_task_planning
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
./scripts/download
```

### "TypeError: unexpected keyword argument 'device'"
**Cause**: MyGroundingDINOSAM2 constructor missing device parameter
**Fix**:
```bash
# Already fixed in current codebase
# If issue persists, check: DovSG/dovsg/perception/models/mygroundingdinosam2.py
# Ensure constructor has: device="cuda" parameter
```

### "Permission denied" editing files
**Cause**: Container files owned by root
**Fix**:
```bash
sudo chown -R $USER:$USER /home/$USER/4DSG/DovSG/
```

### "Missing artifacts (poses_droidslam, memory)"
**Cause**: Preprocessing not run or artifacts not generated
**Fix**:
```bash
# Run full preprocessing first
docker compose exec dovsg python -u demo.py --tags room1 --preprocess --skip_task_planning
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

### "Qt platform plugin" errors
**Cause**: Qt X11 shared memory issues
**Fix**:
```bash
# Already set in Dockerfile: QT_X11_NO_MITSHM=1
# If persists, test manually:
docker exec -it dovsg-main bash -c "export QT_X11_NO_MITSHM=1 && python your_script.py"
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
