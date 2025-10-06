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

**Approximate runtime**: 10-20 minutes

#### Test 3.2: Visualization Only
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
