# Three.js Point Cloud Visualization for DovSG Docker

## Project Overview

**Problem**: DovSG point cloud visualization fails in Docker containers due to headless environment (no GUI/display access).

**Solution**: Implement a web-based Three.js point cloud viewer accessible through browser, eliminating the need for X11 forwarding or VNC setups.

## Architecture Design

```
┌─────────────────┐    HTTP    ┌──────────────────┐    API    ┌─────────────────┐
│   Host Browser  │ ◄────────► │  Docker Container│ ◄───────► │  DovSG Pipeline │
│                 │   :8080    │                  │           │                 │
│  Three.js UI    │            │  Flask/FastAPI   │           │  Point Cloud    │
│  Point Cloud    │            │  Web Server      │           │  Data (.ply)    │
│  Visualization  │            │                  │           │                 │
└─────────────────┘            └──────────────────┘           └─────────────────┘
```

## Implementation Plan

### Phase 1: Backend API Server (2-3 hours)
**Goal**: Create a web server inside the DovSG Docker container

#### 1.1 Install Web Framework
```dockerfile
# Add to Dockerfile.dovsg
RUN pip install flask flask-cors
```

#### 1.2 Create Point Cloud Data API
**File**: `/app/dovsg/web_viewer/api_server.py`
```python
from flask import Flask, jsonify, send_file, render_template
import numpy as np
import open3d as o3d
import json
import os

app = Flask(__name__)

@app.route('/api/pointcloud/<scene_tag>')
def get_pointcloud_data(scene_tag):
    # Load point cloud data using existing DovSG functions
    # Convert to JSON format for Three.js
    # Return structured data
    pass

@app.route('/api/poses/<scene_tag>')
def get_poses_data(scene_tag):
    # Load camera poses
    # Convert to Three.js camera format
    pass

@app.route('/')
def index():
    return render_template('viewer.html')
```

#### 1.3 Data Format Conversion
**Function**: Convert DovSG point clouds to Three.js compatible formats
- RGB values: `[r, g, b]` arrays
- XYZ coordinates: `[x, y, z]` arrays
- Poses: Camera transformation matrices

### Phase 2: Frontend Three.js Viewer (3-4 hours)
**Goal**: Create interactive 3D point cloud visualization

#### 2.1 Three.js Setup
**File**: `/app/dovsg/web_viewer/templates/viewer.html`
```html
<!DOCTYPE html>
<html>
<head>
    <title>DovSG Point Cloud Viewer</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>
</head>
<body>
    <div id="container"></div>
    <div id="controls">
        <select id="sceneSelector">
            <option value="room1">Room 1</option>
        </select>
        <button id="loadScene">Load Scene</button>
    </div>
    <script src="/static/pointcloud-viewer.js"></script>
</body>
</html>
```

#### 2.2 Three.js Point Cloud Renderer
**File**: `/app/dovsg/web_viewer/static/pointcloud-viewer.js`
```javascript
class PointCloudViewer {
    constructor() {
        this.scene = new THREE.Scene();
        this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        this.renderer = new THREE.WebGLRenderer();
        this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
    }

    loadPointCloud(data) {
        // Create THREE.Points object from data
        // Add to scene
        // Update camera position
    }

    loadCameraPoses(poses) {
        // Visualize camera trajectory
        // Add camera frustums
    }
}
```

### Phase 3: Docker Integration (1 hour)
**Goal**: Expose web server from Docker container

#### 3.1 Update Docker Compose
**File**: `docker/docker-compose.yml`
```yaml
services:
  dovsg:
    # ... existing configuration
    ports:
      - "8080:8080"  # Expose web server port
    environment:
      - DISPLAY_MODE=web  # Flag for web mode
```

#### 3.2 Update Container Startup
```dockerfile
# Add to Dockerfile.dovsg
EXPOSE 8080
# Optional: Add startup script to launch web server
```

### Phase 4: Integration with DovSG (2 hours)
**Goal**: Connect to existing DovSG point cloud generation

#### 4.1 Modify show_pointcloud.py
Add web server mode:
```python
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--web-server', action='store_true', help='Launch web server instead of GUI')
    parser.add_argument('--port', default=8080, type=int)

    if args.web_server:
        launch_web_server(args.port)
    else:
        # existing GUI code
```

#### 4.2 Data Pipeline Integration
- Reuse existing point cloud processing functions
- Convert Open3D point clouds to Three.js format
- Maintain compatibility with existing DovSG workflow

## Technical Specifications

### Point Cloud Data Format
```json
{
  "points": {
    "positions": [x1, y1, z1, x2, y2, z2, ...],
    "colors": [r1, g1, b1, r2, g2, b2, ...],
    "count": 12345
  },
  "cameras": [
    {
      "position": [x, y, z],
      "rotation": [rx, ry, rz, rw],
      "matrix": [4x4 transformation matrix]
    }
  ],
  "metadata": {
    "scene": "room1",
    "timestamp": "2025-01-XX",
    "total_points": 12345
  }
}
```

### Performance Optimizations
- **Level-of-Detail (LOD)**: Show fewer points when zoomed out
- **Point size scaling**: Adaptive point sizes based on distance
- **Chunk loading**: Load point clouds in chunks for large datasets
- **Caching**: Cache processed data for faster reload

### User Interface Features
- 🎮 **Interactive controls**: Orbit, zoom, pan
- 📊 **Scene selection**: Dropdown to select different scenes
- 📷 **Camera poses**: Toggle camera trajectory visualization
- 🎨 **Rendering options**: Point size, color modes
- 📱 **Responsive design**: Works on desktop and mobile

## Libraries and Dependencies

### Backend
- **Flask**: Web server framework
- **Open3D**: Point cloud processing (already installed)
- **NumPy**: Data processing (already installed)

### Frontend
- **Three.js**: 3D graphics library
- **OrbitControls**: Camera controls
- **dat.GUI** (optional): Control panel for parameters

## Testing Strategy

### Manual Testing
1. **Load point cloud data**: Verify data loads correctly
2. **Interactive navigation**: Test zoom, rotate, pan
3. **Multiple scenes**: Switch between different room scenes
4. **Performance**: Test with large point clouds (~100k+ points)

### Browser Compatibility
- ✅ Chrome/Chromium (primary target)
- ✅ Firefox
- ✅ Safari (macOS)
- ✅ Mobile browsers

## Deployment Instructions

### Development Mode
```bash
# Start web server in development
cd docker/
docker compose exec dovsg python dovsg/web_viewer/api_server.py
# Open browser: http://localhost:8080
```

### Production Mode
```bash
# Start as service in container
docker compose up -d
# Access: http://localhost:8080
```

## Future Enhancements (Optional)

### Advanced Features
- **Real-time updates**: WebSocket for live point cloud updates
- **Multi-scene comparison**: Side-by-side scene viewing
- **Measurements**: Distance/area measurement tools
- **Export**: Save viewports as images/videos
- **VR support**: WebXR for virtual reality viewing

### Integration Opportunities
- **Jupyter notebooks**: Embed viewer in notebooks
- **REST API**: Full API for external applications
- **Plugin system**: Extensible visualization plugins

## Success Criteria

### Minimum Viable Product (MVP)
- ✅ Point cloud data loads and displays correctly
- ✅ Interactive 3D navigation (orbit, zoom, pan)
- ✅ Accessible through browser at localhost:8080
- ✅ Works with existing DovSG room1 dataset

### Enhanced Version
- ✅ Multiple scene support
- ✅ Camera pose visualization
- ✅ Performance optimizations for large datasets
- ✅ Responsive UI with controls

## Timeline Estimate

**Total Development Time**: ~8-10 hours

- **Phase 1** (Backend): 2-3 hours
- **Phase 2** (Frontend): 3-4 hours
- **Phase 3** (Docker): 1 hour
- **Phase 4** (Integration): 2 hours
- **Testing & Polish**: 1-2 hours

## Risk Assessment

### Low Risk
- Three.js is mature and well-documented
- Point cloud visualization is a common use case
- Docker port exposure is straightforward

### Medium Risk
- Performance with very large point clouds (>1M points)
- WebGL compatibility across different systems

### Mitigation Strategies
- Implement progressive loading for large datasets
- Provide fallback options for unsupported browsers
- Test on multiple platforms during development

---

**Next Steps**:
1. Get user approval for this approach
2. Start with Phase 1 (Backend API Server)
3. Implement MVP version first, then enhance