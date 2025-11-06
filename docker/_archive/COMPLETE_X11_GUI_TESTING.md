# Complete X11 GUI Testing Guide for DovSG Docker Environment

> **DEPRECATED**: This document has been archived. Content has been merged into the authoritative documentation:
> - X11/Wayland setup → [../README.md](../README.md#x11-forwarding-for-gui-visualization)
> - GUI tests → [../MANUAL_VERIFICATION.md](../MANUAL_VERIFICATION.md#1-environment-tests)
> - OpenGL/Open3D tests → [../MANUAL_VERIFICATION.md](../MANUAL_VERIFICATION.md#test-15-opengl-support)
> - X11 troubleshooting → [../MANUAL_VERIFICATION.md](../MANUAL_VERIFICATION.md#troubleshooting-tests)

This guide provides comprehensive step-by-step instructions to test the new X11 GUI capabilities integrated with the existing DovSG Docker environment.

## Phase 0: Build and Setup (Required First)

### Step 0.1: Prerequisites Check
```bash
# Navigate to docker directory
cd /home/cerlab/4DSG/docker

# Verify Docker Compose v2 and GPU support
docker compose version
nvidia-smi

# Expected output:
# - Docker Compose version 2.x.x
# - GPU information display
```

### Step 0.2: Rebuild Containers with X11 Support
```bash
# Build dovsg container with X11 extensions
docker-compose build dovsg

# Build droid-slam container (unchanged but ensure updated)
docker-compose build droid-slam

# Expected output: Successful build messages without errors
# Build should include installation of X11 packages in dovsg container
```

### Step 0.3: Enable X11 Forwarding
```bash
# For X11 systems (traditional Linux)
xhost +local:docker

# For Wayland systems (Ubuntu 22.04+, newer desktops)
# If above fails, also try:
export WAYLAND_DISPLAY=""  # Force XWayland
xhost +SI:localuser:root

# Expected output: "access control disabled, clients can connect from any host"
```

### Step 0.4: Start Containers
```bash
# Start both containers
docker-compose up -d

# Verify container status
docker-compose ps

# Expected output: Both dovsg-main and dovsg-droid-slam containers running
```

## Phase 1: X11 GUI Functionality Tests

### Step 1.1: Test Basic X11 Connection
```bash
# Test X11 connection with simple application
docker exec -it dovsg-main bash -c "echo \$DISPLAY && xeyes"

# Expected output:
# - Display value (e.g., ":0")
# - xeyes application window should appear on your desktop
# - Window should be interactive (eyes follow mouse cursor)
```

### Step 1.2: Test OpenGL Support
```bash
# Test OpenGL direct rendering
docker exec -it dovsg-main glxinfo | grep "direct rendering"

# Test basic OpenGL demo
docker exec -it dovsg-main glxgears

# Expected output:
# - "direct rendering: Yes"
# - Rotating gears window should appear on desktop
# - FPS counter should display in terminal
# - Close window with Ctrl+C in terminal
```

### Step 1.3: Test Open3D GUI Support
```bash
# Test Open3D basic visualization
docker exec -it dovsg-main conda run -n dovsg python -c "
import open3d as o3d
print('Testing Open3D GUI...')
mesh = o3d.geometry.TriangleMesh.create_coordinate_frame(size=1.0)
print('Created coordinate frame')
o3d.visualization.draw_geometries([mesh])
print('Visualization completed')
"

# Expected output:
# - Text messages in terminal
# - 3D coordinate frame window appears on desktop
# - Window should be interactive (mouse drag to rotate, wheel to zoom)
# - Close window to continue script
```

### Step 1.4: Test Image Viewers
```bash
# Test PIL image viewer
docker exec -it dovsg-main conda run -n dovsg python -c "
from PIL import Image
import numpy as np
img_data = np.random.randint(0, 255, (300, 300, 3), dtype=np.uint8)
img = Image.fromarray(img_data)
img.show()
"

# Expected output:
# - Random colored image window appears on desktop
# - Image viewer window should be native system viewer
```

## Phase 2: DovSG-Specific GUI Testing

### Step 2.1: Test DovSG Point Cloud Visualization
```bash
# Run DovSG point cloud visualization (if data exists)
docker exec -it dovsg-main conda run -n dovsg python dovsg/scripts/show_pointcloud.py \
    --tags "room1" \
    --pose_tags "poses_droidslam"

# Expected output:
# - Loading progress messages in terminal
# - 3D point cloud window appears on desktop showing room scene
# - Window should be interactive with Open3D controls
# - Colored point cloud representing room geometry
```

### Step 2.2: Test DovSG Demo with Interactive Visualization
```bash
# Run DovSG demo with preprocessing and debug visualization
docker exec -it dovsg-main conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug

# Expected output sequence:
# 1. Terminal messages showing processing steps
# 2. Multiple GUI windows may appear during processing:
#    - Point cloud visualizations
#    - Debug image windows
#    - Interactive 3DSG viewer with keyboard controls
# 3. Final interactive 3DSG viewer window (1280x720) with these controls:
#    - B: Toggle background
#    - C: Color by class
#    - R: Color by RGB
#    - F: Color by CLIP similarity
#    - G: Toggle scene graph
#    - I: Color by instance
#    - O: Toggle bounding boxes
#    - V: Save view parameters
```

### Step 2.3: Test Interactive 3DSG Viewer Controls
When the main 3DSG viewer window appears:

```bash
# Test all keyboard controls (press keys while viewer window is focused):
# B - Should toggle background point cloud visibility
# C - Should color objects by semantic class
# R - Should color objects by RGB appearance
# F - Should color by CLIP feature similarity
# G - Should toggle scene graph relationship lines
# I - Should color by instance segmentation
# O - Should toggle bounding box visibility
# V - Should save current view parameters

# Test mouse controls:
# - Left drag: Rotate view
# - Right drag: Pan view
# - Scroll wheel: Zoom in/out
# - All interactions should be smooth and responsive
```

## Phase 3: Integration with Existing Workflow

### Step 3.1: Follow Original Manual Verification
```bash
# Run the complete manual verification from MANUAL_VERIFICATION.md
# All existing tests should work PLUS new GUI capabilities

# Check container status (from original guide)
./scripts/start --status

# Test container functionality (from original guide)
./scripts/start --test

# Expected output: Same as original guide plus GUI support confirmed
```

### Step 3.2: DROID-SLAM with GUI Testing
```bash
# Test DROID-SLAM (should work same as before, but now with potential GUI)
# Note: DROID-SLAM typically runs with --disable_vis for Docker
docker compose exec droid-slam bash -c "cd /app/DROID-SLAM && conda run -n droidenv python demo.py --imagedir=/app/data_example/room1/rgb --calib=/app/data_example/room1/calib.txt --t0=0 --stride=2 --weights=/app/checkpoints/droid-slam/droid.pth --buffer=256 --disable_vis"

# Expected output: Same pose estimation results as before
# No new GUI windows expected (DROID-SLAM uses --disable_vis)
```

### Step 3.3: Full Pipeline Test with GUI
```bash
# Run complete DovSG pipeline with task
docker exec -it dovsg-main conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_scene_change_level "Minor Adjustment" \
    --task_description "Please move the red pepper to the plate, then move the green pepper to plate."

# Expected output:
# 1. All original pipeline functionality preserved
# 2. Additional GUI windows for visualization steps
# 3. Interactive 3DSG viewer as final output
# 4. All keyboard controls functional
# 5. Task planning results in terminal
```

## Phase 4: Success Criteria and Validation

### Step 4.1: GUI Integration Success Criteria
Your X11 GUI implementation is successful if:

1. **Basic X11 Works**: xeyes and glxgears appear on desktop
2. **OpenGL Acceleration**: "direct rendering: Yes" confirmed
3. **Open3D Integration**: Coordinate frame visualization works interactively
4. **Image Viewers**: PIL/OpenCV images display in system viewers
5. **DovSG Visualization**: Point cloud scripts show 3D scenes on desktop
6. **Interactive 3DSG Viewer**: Main viewer opens with all 8 keyboard controls working
7. **Seamless Integration**: All original functionality preserved
8. **Window Management**: GUI windows appear natively, can be moved/resized
9. **No Performance Loss**: Same processing speeds as before
10. **Error-Free Operation**: No X11-related error messages

### Step 4.2: Expected GUI Windows During Full Demo
1. **Point Cloud Viewers**: Multiple Open3D windows showing scene geometry
2. **Debug Image Windows**: PIL/ImageMagick windows showing processing steps
3. **Interactive 3DSG Viewer**: Final 1280x720 window with keyboard controls
4. **System Image Viewers**: Native viewers for debug outputs

### Step 4.3: Performance Validation
```bash
# Monitor GPU usage during GUI operations
docker exec -it dovsg-main nvidia-smi

# Expected output:
# - Similar GPU memory usage as before
# - No significant performance degradation
# - Graphics capability should be listed in NVIDIA driver capabilities
```

## Phase 5: Troubleshooting

### Common X11 Issues and Solutions

**Issue: "cannot connect to X server"**
```bash
# Check display variable
docker exec -it dovsg-main bash -c "echo \$DISPLAY"
# Should show ":0" or similar

# Re-enable X11 forwarding
xhost +local:docker
export DISPLAY=:0
```

**Issue: "No protocol specified" or "authorization required"**
```bash
# For Wayland systems
export WAYLAND_DISPLAY=""
xhost +SI:localuser:root

# Alternative: disable access control temporarily
xhost +
```

**Issue: GUI windows appear but are blank/corrupted**
```bash
# Check graphics drivers
docker exec -it dovsg-main glxinfo | grep "OpenGL renderer"
# Should show your GPU, not software rendering

# Test with simple graphics
docker exec -it dovsg-main xlogo
```

**Issue: "Qt platform plugin" errors**
```bash
# Set Qt environment variables
docker exec -it dovsg-main bash -c "export QT_X11_NO_MITSHM=1 && python your_script.py"
# Already set in Dockerfile, but can test manually
```

**Issue: Open3D windows don't respond to keyboard**
```bash
# Ensure window has focus
# Click on the Open3D window before pressing keys
# Try pressing keys with window active

# Test basic keyboard input
docker exec -it dovsg-main conda run -n dovsg python -c "
import open3d as o3d
vis = o3d.visualization.VisualizerWithKeyCallback()
vis.create_window()
print('Press Q to quit, other keys for testing')
def key_callback(vis):
    print('Key pressed!')
    return False
vis.register_key_callback(ord('Q'), key_callback)
vis.run()
"
```

### Reverting to Headless Mode (if needed)
If GUI causes issues, you can temporarily disable X11:

```bash
# Remove X11 forwarding environment
docker exec -it dovsg-main bash -c "unset DISPLAY"

# Or run with modified environment
docker exec -it dovsg-main bash -c "DISPLAY= python demo.py --tags room1"
```

## Phase 6: Development Integration

### Step 6.1: Development Workflow with GUI
```bash
# Interactive development with GUI support
docker exec -it dovsg-main bash
# Inside container:
conda activate dovsg
export DISPLAY=:0  # Ensure X11 forwarding active
python demo.py --tags room1 --debug  # GUI windows appear on desktop
```

### Step 6.2: Script Integration
```bash
# Use enhanced demo script (if available)
./scripts/demo

# Should now support GUI options
# GUI visualization should work in interactive mode
```

## Summary

This testing guide verifies that:
1. **X11 GUI support** is properly integrated
2. **Original functionality** is completely preserved
3. **Interactive visualization** works seamlessly
4. **Desktop integration** provides native window experience
5. **Development workflow** supports both GUI and headless modes

The implementation successfully adds GUI capabilities while maintaining the existing DovSG Docker architecture and all original functionality.