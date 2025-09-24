# DovSG Docker Environment Manual Verification Guide

This guide provides step-by-step instructions to manually verify that the DovSG Docker environment is working properly. Follow these instructions to test each component and validate the complete pipeline.

## Prerequisites

Ensure you have completed the initial setup:
- Docker and NVIDIA Container Toolkit installed
- Containers built and running
- Sample data downloaded to `DovSG/data_example/room1/`
- Model checkpoints downloaded

## Phase 1: Environment Verification

### Step 1.1: Verify Working Directory
```bash
# Navigate to docker directory
cd docker/

# Verify you're in the correct location
pwd
# Expected output: /path/to/4DSG/docker

ls
# Expected output: docker-compose.yml, dockerfiles/, scripts/
```

### Step 1.2: Check Container Status
```bash
# Check container status
./scripts/start --status

# Expected output:
# Container Status:
# ===================
# Containers are running:
# NAME               IMAGE               COMMAND                SERVICE      CREATED        STATUS        PORTS
# dovsg-droid-slam   docker-droid-slam   ...                    droid-slam   X hours ago    Up X hours
# dovsg-main         docker-dovsg        ...                    dovsg        X hours ago    Up X hours    0.0.0.0:8888->8888/tcp
```

### Step 1.3: Test Container Functionality
```bash
# Run container functionality tests
./scripts/start --test

# Expected output:
# Testing containers...
#
# Testing DovSG container:
# Python 3.9.X
# DovSG container working
#
# Testing DROID-SLAM container:
# Python 3.9.X
# DROID-SLAM container working
#
# Testing GPU access:
# [GPU information should display]
# GPU access working
```

### Step 1.4: Verify Sample Data
```bash
# Check sample data structure
ls -la ../DovSG/data_example/room1/

# Expected output should include:
# - rgb/ (directory with .jpg files)
# - depth/ (directory with .npy files)
# - mask/ (directory with .npy files)
# - point/ (directory with .npy files)
# - calibration/ (directory)
# - calib.txt (calibration file)
# - metadata.json
```

### Step 1.5: Verify Model Checkpoints
```bash
# Check checkpoints
ls -la ../DovSG/checkpoints/

# Expected output should include directories:
# - droid-slam/
# - GroundingDINO/
# - segment-anything-2/
# - recognize_anything/
# - bert-base-uncased/
# - CLIP-ViT-H-14-laion2B-s32B-b79K/
# - anygrasp/

# Verify critical checkpoint exists
ls -la ../DovSG/checkpoints/droid-slam/droid.pth
# Expected: File should exist and be approximately 150MB
```

## Phase 2: DROID-SLAM Testing

### Step 2.1: Test DROID-SLAM Help
```bash
# Test DROID-SLAM demo access
docker compose exec droid-slam bash -c "cd /app/DROID-SLAM && conda run -n droidenv python demo.py --help"

# Expected output: Help message with all available arguments including:
# --imagedir, --calib, --weights, --buffer, etc.
```

### Step 2.2: Run DROID-SLAM Pose Estimation

**Important**: Use the corrected command below. The original data is in the `rgb/` subdirectory and requires smaller buffer size for typical hardware:

```bash
# Method 1: Verify DROID-SLAM works (verification only - no pose output saved)
docker compose exec droid-slam bash -c "cd /app/DROID-SLAM && conda run -n droidenv python demo.py --imagedir=/app/data_example/room1/rgb --calib=/app/data_example/room1/calib.txt --t0=0 --stride=2 --weights=/app/checkpoints/droid-slam/droid.pth --buffer=256 --disable_vis"

# Method 2: Create poses_droidslam/ directory (DovSG pose estimation - WORKING!)
# First apply required DovSG modification to DROID-SLAM (one-time fix):
docker exec dovsg-droid-slam sed -i 's/for (tstamp, image, intrinsic) in image_stream:/for (tstamp, image, _, intrinsic) in image_stream:/' /app/DROID-SLAM/droid_slam/trajectory_filler.py

# Then run pose estimation:
docker exec dovsg-droid-slam bash -c "cd /app && PYTHONPATH=/app/DROID-SLAM/droid_slam:/app/DROID-SLAM:\$PYTHONPATH conda run -n droidenv python dovsg/scripts/pose_estimation.py --datadir \"data_example/room1\" --calib \"data_example/room1/calib.txt\" --weights \"checkpoints/droid-slam/droid.pth\" --stride=1 --buffer=256"
```

**Parameter Explanations:**
- `--imagedir`: Path to RGB images directory (must point to `room1/rgb` not `room1`)
- `--calib`: Camera calibration file (contains intrinsic parameters: fx, fy, cx, cy)
- `--t0`: Starting frame index (0 = begin from first image)
- `--stride`: Frame step size (2 = process every 2nd frame for speed/memory)
- `--weights`: Path to pre-trained DROID-SLAM model weights
- `--buffer`: Memory buffer size (256 works on 8GB GPU, 512+ may cause OOM)
- `--disable_vis`: Disable visualization (required for headless Docker environment)


### Step 2.3: Verify DROID-SLAM Output
```bash
# Check if poses were generated
ls -la ../DovSG/data_example/room1/poses_droidslam/

# Expected output: Directory should contain pose files
# If empty, that's normal as we may be using existing poses

```

## Phase 3: DovSG Point Cloud Visualization

### Step 3.1: Test Point Cloud Visualization Script
```bash
# Run point cloud visualization
docker compose exec dovsg conda run -n dovsg python dovsg/scripts/show_pointcloud.py \
    --tags "room1" \
    --pose_tags "poses_droidslam"

# Expected output:
# - Loading progress messages
# - Point cloud visualization window should open
# - Should display colored 3D point cloud of the room scene
# - Window should be interactive (rotation, zoom)
```

### Step 3.2: Verify Point Cloud Controls
In the visualization window, test these controls:
- Mouse drag: Rotate view
- Mouse wheel: Zoom in/out
- Window should show room scene with furniture/objects

## Phase 4: DovSG Demo Testing

### Step 4.1: Test DovSG Demo Help
```bash
# Test demo help
docker compose exec dovsg conda run -n dovsg python demo.py --help

# Expected output: Help message showing all available arguments:
# --tags, --preprocess, --debug, --scanning_room, --task_description, etc.
```

### Step 4.2: Run DovSG Preprocessing
```bash
# Run preprocessing only (safe first test)
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess

# Expected output sequence:
# 1. Pose estimation messages
# 2. Point cloud generation
# 3. Floor transformation
# 4. ACE training progress
# 5. Point cloud visualization
# Should complete without errors
```

### Step 4.3: Run Full DovSG Demo
```bash
# Run complete demo with task
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_scene_change_level "Minor Adjustment" \
    --task_description "Please move the red pepper to the plate, then move the green pepper to plate."

# Expected output sequence:
# 1. Preprocessing steps (as above)
# 2. View dataset generation
# 3. Semantic memory construction
# 4. Instance detection and segmentation
# 5. Scene graph construction
# 6. LightGlue feature extraction
# 7. 3D visualization with interactive controls
# 8. Task planning output
# 9. Task execution (if applicable)
```

### Step 4.4: Test Interactive Visualization
When the 3D visualization opens, test these controls:
- Press "B": Show/hide background
- Press "C": Color by class
- Press "R": Color by RGB
- Press "F": Color by CLIP similarity
- Press "G": Toggle scene graph display
- Press "I": Color by instance
- Press "O": Toggle bounding boxes
- Press "V": Save view parameters

## Phase 5: Alternative Script Testing

### Step 5.1: Test Demo Script Interface
```bash
# Use the streamlined demo script
./scripts/demo

# Expected interactive menu:
# DovSG Demo Runner
# ==================
# Containers are running
# Sample data found
#
# Demo Options:
# ==============
# 1. Show demo help
# 2. Run full demo with sample data
# 3. Run preprocessing only
# 4. Run DROID-SLAM pose estimation
# 5. Run custom demo

# Test each option:
# Option 1: Should show help
# Option 3: Should run preprocessing
# Option 4: Should run DROID-SLAM (our fixed version)
# Option 2: Should run full demo
```

## Phase 6: Performance Validation

### Step 6.1: Memory Usage Check
```bash
# Check GPU memory usage during demo
docker compose exec dovsg nvidia-smi

# Expected output:
# GPU memory usage should be reasonable (not 100%)
# Process should show python processes using GPU
```

### Step 6.2: Timing Validation
Expected approximate timing for key operations:
- DROID-SLAM pose estimation: 2-5 minutes
- DovSG preprocessing: 10-15 minutes
- Scene graph construction: 5-10 minutes
- Full demo completion: 15-30 minutes

## Troubleshooting

### Common Issues and Solutions

**Issue: "Containers not running"**
```bash
./scripts/start
```

**Issue: "GPU access not working"**
```bash
# Check NVIDIA Docker runtime
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# If fails, reinstall NVIDIA Container Toolkit (see main README)
```

**Issue: "Sample data not found"**
Download from [Google Drive](https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing) and extract to `DovSG/data_example/room1/`

**Issue: "Checkpoints missing"**
```bash
./scripts/download
```

**Issue: "DROID-SLAM CUDA out of memory"**
```bash
# Reduce buffer size (try these in order):
--buffer=128    # For 4GB GPU
--buffer=256    # For 8GB GPU
--buffer=512    # For 12GB+ GPU

# Or increase stride to skip frames:
--stride=3      # Process every 3rd frame
--stride=4      # Process every 4th frame
```

**Issue: "DROID-SLAM Qt platform plugin error"**
```bash
# Always add --disable_vis for headless Docker:
--disable_vis
```

**Issue: "DROID-SLAM 'NoneType' has no attribute 'shape'"**
```bash
# Wrong image directory path, fix with:
--imagedir=/app/data_example/room1/rgb   # Point to rgb/ subdirectory
```

**Issue: "Module not found errors"**
```bash
# Rebuild containers
./scripts/build --no-cache
```

**Issue: "OpenGL/visualization problems"**
```bash
# Check X11 forwarding (if using SSH)
ssh -X username@hostname

# Or use container shell for headless operation
docker compose exec dovsg bash
```

**Issue: "DROID-SLAM import errors"**
This was fixed in our environment. The error indicates the old broken integration. Our environment uses the native DROID-SLAM method which works correctly.

## Success Criteria

Your Docker environment is working correctly if:

1. All containers start and respond to basic tests
2. GPU access is functional
3. DROID-SLAM can process the sample data without import errors
4. Point cloud visualization displays the room scene
5. DovSG preprocessing completes without crashes
6. Interactive 3D visualization opens with proper controls
7. Full demo can execute task planning pipeline

## Expected File Outputs

After successful runs, you should see these generated files:

```bash
# Check generated outputs
ls -la ../DovSG/data_example/room1/

# Should include (if not already present):
# - poses_droidslam/ (pose files from DROID-SLAM)
# - ace/ (ACE model outputs)
# - memory/ (semantic memory files)
```

## Performance Benchmarks

On a system with RTX 4090 GPU:
- DROID-SLAM: ~739 frames in 2-3 minutes
- DovSG preprocessing: ~15 minutes total
- Interactive visualization: Real-time frame rates
- Memory usage: ~5-7GB GPU VRAM

Your results may vary based on hardware, but the operations should complete successfully without errors.

## Next Steps

Once manual verification is complete:
1. Use `./scripts/demo` for routine testing
2. Modify DovSG code directly in `DovSG/` directory
3. Changes reflect immediately in containers (live code editing)
4. Run tests using the streamlined scripts

For development work, you can access container shells:
```bash
# DovSG development
docker compose exec dovsg bash
conda run -n dovsg python your_script.py

# DROID-SLAM development
docker compose exec droid-slam bash
conda run -n droidenv python your_script.py
```