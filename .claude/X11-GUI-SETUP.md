# DovSG Docker X11 GUI Setup

## Quick Start Commands

### 1. Enable X11 forwarding (run once per session)
```bash
cd /home/cerlab/4DSG/docker

# For X11 systems (traditional Linux)
xhost +local:docker

# For Wayland systems (Ubuntu 22.04+, newer desktops)
# If above fails, also try:
export WAYLAND_DISPLAY=""  # Force XWayland
xhost +SI:localuser:root
```

### 2. Build containers with X11 support
```bash
cd /home/cerlab/4DSG/docker
docker-compose build dovsg
```

### 3. Start containers
```bash
docker-compose up -d
```

### 4. Run DovSG with GUI
```bash
# Run demo with GUI windows appearing on desktop
docker exec -it dovsg-main conda run -n dovsg python demo.py --preprocess --debug --tags room1

# Interactive shell
docker exec -it dovsg-main bash
# Then inside: conda run -n dovsg python demo.py --help
```

## Test GUI Components

### Test Open3D visualization
```bash
docker exec -it dovsg-main conda run -n dovsg python -c "
import open3d as o3d
mesh = o3d.geometry.TriangleMesh.create_coordinate_frame(size=1.0)
o3d.visualization.draw_geometries([mesh])
"
```

### Test DovSG point cloud script
```bash
docker exec -it dovsg-main conda run -n dovsg python dovsg/scripts/show_pointcloud.py --tags room1
```

## Troubleshooting

### X11 connection issues
```bash
# Test X11 connection
docker exec -it dovsg-main bash -c "echo \$DISPLAY && xeyes"
# Should show display and open eyes window

# If "cannot connect to X server":
xhost +local:docker  # Enable X11 permissions
export DISPLAY=:0     # Set correct display
```

### GPU access issues
```bash
# Test GPU access in container
docker exec -it dovsg-main nvidia-smi
# Should show GPU information

# Test OpenGL
docker exec -it dovsg-main glxinfo | grep "direct rendering"
# Should show "direct rendering: Yes"
```