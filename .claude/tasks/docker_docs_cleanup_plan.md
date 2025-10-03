# Docker Documentation & Scripts Cleanup Plan

**Version**: 1.0
**Created**: 2025-01-26
**Purpose**: Streamline Docker documentation and scripts to minimal, current, maintainable set

---

## 1. Chat-Sourced Changes Digest

Changes identified from conversation history (`.claude/worklog.md` and previous discussions) that are NOT fully reflected in current documentation:

### 1.1 Core Code Fixes (must include in both README and MANUAL_VERIFICATION)

| Change | Date | Context | Impact | Target Doc |
|--------|------|---------|--------|------------|
| **`--skip_task_planning` flag** | 2025-01-26 | Added to `demo.py:81` to bypass LLM task planning requiring OpenAI API key | Essential for 3DSG-only workflow | README (common flags), MANUAL_VERIFICATION (test commands) |
| **CLIP query key remapping** | 2025-01-26 | Changed from 'F' → 'Q' (then 'A' per user) in `visualize_instances.py:364` | Interactive viewer controls documentation | MANUAL_VERIFICATION (keyboard controls section) |
| **`device` parameter in MyGroundingDINOSAM2** | 2025-01-26 | Added `device="cuda"` to constructor (`mygroundingdinosam2.py:13-17`) | Fixed TypeError crash at semantic memory init | README (troubleshooting) |
| **Empty objects handling** | 2025-01-26 | Added defensive checks in `instance_process.py:159-170` and `visualize_instances.py:50-71` | Prevents `np.concatenate()` crash with zero detections | README (common pitfalls) |
| **Real-time logging command** | 2025-01-26 | Use `python -u` flag with direct conda activation instead of `conda run` | Shows progress during execution, not buffered until crash | README (development workflow), MANUAL_VERIFICATION (all test commands) |
| **LightGlue device mapping** | 2025-01-26 | Added `map_location=device` in `controller.py:945-946` | Fixed CUDA deserialization error | README (troubleshooting) |

**Real-time logging pattern** (critical for all commands):
```bash
# WRONG (buffered output):
docker exec dovsg-main conda run -n dovsg python demo.py --tags room1

# CORRECT (real-time output):
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1"
```

### 1.2 X11 GUI Integration (must include in README)

| Change | Date | Context | Impact | Target Doc |
|--------|------|---------|--------|------------|
| **X11 forwarding setup** | 2025-09-28 | Added `DISPLAY=${DISPLAY:-:0}` and `/tmp/.X11-unix` volume mount in `docker-compose.yml:44,58` | Enables native GUI windows on host desktop | README (prerequisites, GPU vs Mesa paths) |
| **NVIDIA graphics capability** | 2025-09-28 | Changed `NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute` (line 43) | Required for Open3D OpenGL rendering | README (environment variables) |
| **`xhost +local:docker`** | 2025-09-28 | Required host command before starting containers | Allows Docker containers to access X server | README (setup validation) |

### 1.3 3DSG-Only Workflow (must include in MANUAL_VERIFICATION)

| Change | Date | Context | Impact | Target Doc |
|--------|------|---------|--------|------------|
| **3DSG-only execution pattern** | 2025-09-29 | Assumes preprocessed artifacts exist (`poses_droidslam/`, `memory/`, `ace/`) | Faster iteration without 15-30min preprocessing | MANUAL_VERIFICATION (3DSG-only test section) |
| **Interactive viewer controls** | 2025-01-26 | 8 keyboard controls: B/C/R/A/G/I/O/V (note: 'Q' changed to 'A' by user) | Essential for validation checklist | MANUAL_VERIFICATION (expected outputs) |
| **Expected windows during demo** | 2025-09-26 | Three GUI windows: DROID-SLAM point cloud, View dataset, Interactive 3DSG viewer | Success criteria for GUI validation | MANUAL_VERIFICATION (acceptance checks) |

### 1.4 Container Volume Mount Sync (affects scripts)

| Change | Date | Context | Impact | Target Doc |
|--------|------|---------|--------|------------|
| **Container restart required** | 2025-01-26 | Volume-mounted file changes not visible until `docker compose restart dovsg` | Affects workflow when editing `demo.py` directly | README (development workflow) |
| **File permissions fix** | 2025-01-26 | `sudo chown -R cerlab:cerlab /home/cerlab/4DSG/DovSG/` needed after root-owned files created | Common troubleshooting step | README (troubleshooting), MANUAL_VERIFICATION (prerequisites) |

---

## 2. Inventory Table (Discovery)

### 2.1 Documentation Files

| Path | Purpose | Last Modified | Referenced By | Status | Proposed Action | Rationale |
|------|---------|---------------|---------------|--------|----------------|-----------|
| `docker/README.md` | Current Docker setup guide | 2025-09-23 | Top-level README, scripts | Current but outdated | **EDIT** - Rewrite as "New Device Setup" only | Contains good structure but missing chat-derived changes; needs X11 setup, real-time logging, `--skip_task_planning` |
| `docker/MANUAL_VERIFICATION.md` | Manual testing guide | 2025-09-24 | None (standalone) | Current but outdated | **EDIT** - Update with 3DSG test matrix | Good structure but missing: CLIP key update (Q→A), `--skip_task_planning`, 3DSG-only workflow, expected GUI windows |
| `docker/COMPLETE_X11_GUI_TESTING.md` | X11 GUI testing steps | 2025-09-26 | None | Duplicate content | **MERGE** into `MANUAL_VERIFICATION.md` Phase 6 | Overlap with MANUAL_VERIFICATION; X11 tests should be part of acceptance criteria, not separate doc |
| `docker/3dsg_only_plan.md` | 3DSG-only execution documentation | 2025-09-29 | `run_3dsg_only.sh` | Duplicate content | **MERGE** into `MANUAL_VERIFICATION.md` Section 3DSG-Only | Content already covered by MANUAL_VERIFICATION Phase 4-5; consolidate keyboard controls and artifacts list |
| `README.md` (top-level) | Project overview | 2025-09-13 | GitHub landing page | Current | **KEEP** with minor update | Good high-level overview; add link to `docker/README.md` for setup instructions |
| `DovSG/README.md` | Original DovSG docs | 2024 (upstream) | Original repo | Keep as reference | **KEEP** unchanged | Upstream documentation; don't modify |
| `DovSG/docs/*.md` | Original installation guides | 2024 (upstream) | `DovSG/README.md` | Keep as reference | **KEEP** unchanged | Historical reference for native installation; Docker setup supersedes |
| `.claude/worklog.md` | Development changelog | 2025-01-26 (ongoing) | Internal | Current | **KEEP** and update during implementation | Critical historical record; must be updated with this cleanup effort |

### 2.2 Script Files

| Path | Purpose | Last Modified | Called By | Status | Proposed Action | Rationale |
|------|---------|---------------|-----------|--------|----------------|-----------|
| `scripts/setup` | Complete environment setup | 2025-09-23 | User (first-time setup) | Current | **KEEP** with updates | Primary entry point; needs real-time logging examples, X11 setup, validation steps |
| `scripts/build` | Build Docker containers | 2025-09-23 | `setup`, User | Current | **KEEP** unchanged | Well-structured, no changes needed |
| `scripts/start` | Start/stop/status containers | 2025-09-23 | `setup`, User | Current | **KEEP** with GPU test update | Add X11 connection test to `--test` flag |
| `scripts/demo` | Interactive demo runner | 2025-09-23 | User | Outdated | **EDIT** - Add `--skip_task_planning`, real-time logging | Currently uses buffered `conda run`; needs `python -u` pattern and task planning skip option |
| `scripts/download` | Download model checkpoints | 2025-09-23 | `setup` | Current | **KEEP** unchanged | Works correctly, no issues |
| `scripts/init-dirs` | Create directory structure | 2025-09-23 | `setup` | Current | **KEEP** unchanged | Simple utility, no changes needed |
| `scripts/common.sh` | Shared bash functions | 2025-09-23 | All scripts | Current | **KEEP** unchanged | Well-designed library, no changes needed |
| `scripts/run_3dsg_only.sh` | 3DSG-only execution | 2025-09-29 | User (advanced) | Current | **KEEP** with updates | Unique use case; needs `--skip_task_planning`, real-time logging pattern |

**Script Count**: **8 scripts** → **Target: 5 canonical + 2 utilities**

### 2.3 Compose & Environment Files

| Path | Purpose | Last Modified | Status | Proposed Action | Rationale |
|------|---------|---------------|--------|----------------|-----------|
| `docker/docker-compose.yml` | Multi-service orchestration | 2025-09-28 | Current | **KEEP** with comments | Already includes X11, GPU, PYTHONUNBUFFERED; add inline comments explaining env vars |
| `.env` (does not exist) | N/A | N/A | Missing | **CREATE** `.env.example` | Provide template for optional overrides (DISPLAY, data paths) |
| `compose.override.yml` (does not exist) | N/A | N/A | Missing | **CREATE** `compose.override.example.yml` | Optional GPU variant (Mesa vs NVIDIA) and Wayland hints |

---

## 3. Target Minimal Doc Set (Exactly 2 Files Under /docker)

### 3.1 `docker/README.md` - New Device Setup Only

**Purpose**: Complete guide for setting up DovSG Docker environment on a fresh machine

**Outline** (bullets only):

```markdown
# DovSG Docker Development Environment

## Overview
- What this environment provides (CUDA 12.1, PyTorch 2.3, pre-built dependencies)
- Architecture diagram (dovsg + droid-slam services)
- Link to MANUAL_VERIFICATION.md for testing

## Prerequisites
### System Requirements
- Ubuntu 20.04/22.04/24.04 (tested)
- NVIDIA GPU (recommended) OR Mesa OpenGL (CPU fallback)
- 32GB RAM, 50GB disk space

### Software Installation
- Docker Engine (installation commands)
- Docker Compose v2 (installation commands)
- NVIDIA Container Toolkit (GPU path)
  - nvidia-smi verification
  - nvidia-ctk runtime configuration
  - docker --gpus all test
- Mesa drivers (CPU fallback path)
  - When to use: No NVIDIA GPU, testing, headless servers
  - Installation: libgl1-mesa-glx, libglu1-mesa
  - Limitations: Software rendering, slower visualization

### X11 GUI Setup (Required for Visualization)
- Enable X11 forwarding: `xhost +local:docker`
- Wayland systems: `export WAYLAND_DISPLAY=""`
- Verify: `echo $DISPLAY` should show `:0`
- Security note: `xhost -local:docker` to disable after use

## Quick Start
### 1. Clone Repository
- git clone commands
- Recursive submodule initialization

### 2. One-Command Setup
- `cd docker && ./scripts/setup`
- What it does: init dirs, download checkpoints, build containers, start services
- Expected duration: 45-90 minutes (first time)

### 3. Download Sample Data
- Manual step: Google Drive link
- Extract location: `DovSG/data_example/room1/`
- Expected size: ~23GB

### 4. Validation
- `./scripts/start --test` (GPU, containers, Python)
- `xhost +local:docker` (X11)
- Link to MANUAL_VERIFICATION.md Phase 1

## Development Workflow
### Live Code Editing
- Edit files in `DovSG/` directly (volume-mounted)
- No rebuild needed for Python changes
- **Container restart required** if editing `demo.py` or scripts: `docker compose restart dovsg`
- Rebuild only for Dockerfile changes: `./scripts/build --dovsg --no-cache`

### Running Commands
- **Real-time logging pattern** (CRITICAL):
  ```bash
  docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1"
  ```
- Why `python -u`: Unbuffered output shows progress, not buffered until crash
- Why not `conda run`: Doesn't respect PYTHONUNBUFFERED environment variable

### Interactive Shell
- `docker exec -it dovsg-main bash`
- Inside: `conda activate dovsg`, then run commands
- Exit: `exit` or Ctrl+D

### Common Command Patterns
- Full preprocessing: `python -u demo.py --tags room1 --preprocess --skip_task_planning`
- 3DSG only: `./scripts/run_3dsg_only.sh room1`
- Point cloud viz: `python dovsg/scripts/show_pointcloud.py --tags room1 --pose_tags poses_droidslam`
- DROID-SLAM: Link to MANUAL_VERIFICATION.md Phase 2

## Environment Variables Reference
| Variable | Value | Purpose | Set In |
|----------|-------|---------|--------|
| `DISPLAY` | `:0` (default) | X11 display for GUI windows | docker-compose.yml:44 |
| `PYTHONUNBUFFERED` | `1` | Real-time output, no buffering | docker-compose.yml:45 |
| `NVIDIA_VISIBLE_DEVICES` | `all` | Expose all GPUs to containers | docker-compose.yml:42 |
| `NVIDIA_DRIVER_CAPABILITIES` | `graphics,utility,compute` | Enable GPU + OpenGL rendering | docker-compose.yml:43 |

**Optional Overrides** (create `.env` file in `docker/` directory):
```bash
DISPLAY=:1              # Custom display
DATA_PATH=/custom/path  # Alternative data location
```

## Compose File Structure
- Single `docker-compose.yml` for all environments
- Optional `compose.override.yml` for custom GPU configs (see `.env.example`)
- Services: dovsg (main), droid-slam (pose estimation)
- Shared volumes: checkpoints, data_example, shared_data, source code

## Common Flags Reference
| Flag | Purpose | Example |
|------|---------|---------|
| `--tags` | Scene identifier | `--tags room1` |
| `--preprocess` | Run full preprocessing (DROID-SLAM, floor alignment, ACE training) | Required first time |
| `--debug` | Enable debug output and visualizations | More verbose logs |
| `--skip_task_planning` | Skip LLM task planning (no OpenAI API key needed) | **Essential for 3DSG-only workflow** |
| `--task_description` | Natural language task (requires API key) | `--task_description "move red pepper to plate"` |
| `--task_scene_change_level` | Scene change severity | `--task_scene_change_level "Minor Adjustment"` |

## Common Pitfalls & Solutions
### "Permission denied" editing files
```bash
sudo chown -R $USER:$USER /path/to/4DSG/DovSG/
```
**Why**: Container runs as root, creates root-owned files

### "TypeError: unexpected keyword argument 'device'"
**Fixed in current version**. If encountered, update `DovSG/dovsg/perception/models/mygroundingdinosam2.py:13-17`:
```python
def __init__(self, box_threshold=0.8, text_threshold=0.8, nms_threshold=0.5, device="cuda"):
    self.device = device
```

### "ValueError: need at least one array to concatenate"
**Fixed in current version**. Occurs with mock detector returning zero detections. Empty objects handling added to `instance_process.py:159-170` and `visualize_instances.py:50-71`.

### "RuntimeError: Attempting to deserialize object on a CUDA device"
**Fixed in current version**. LightGlue device mapping added in `controller.py:945-946`.

### White screen in Open3D viewer
- **Cause**: Mock MyGroundingDINOSAM2 returns no detections
- **Workaround**: Press 'B' to toggle background point cloud
- **Solution**: Replace with real GroundingDINO integration (future work)

### GUI windows not appearing
```bash
# Enable X11 forwarding
xhost +local:docker
export DISPLAY=:0

# Verify in container
docker exec dovsg-main bash -c "echo \$DISPLAY"
# Should output: :0

# Test with simple app
docker exec dovsg-main bash -c "DISPLAY=:0 xeyes"
# Should show xeyes window on desktop
```

### `--skip_task_planning` flag not recognized
**Cause**: Container not synced with volume-mounted file changes
```bash
docker compose restart dovsg
```

### Buffered output (progress not showing)
**Cause**: Using `conda run` instead of `python -u`
```bash
# WRONG (buffered):
docker exec dovsg-main conda run -n dovsg python demo.py --tags room1

# CORRECT (real-time):
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1"
```

## Troubleshooting Workflow
1. Check container status: `./scripts/start --status`
2. Test container functionality: `./scripts/start --test`
3. Check GPU access: `docker exec dovsg-main nvidia-smi`
4. Check X11 forwarding: `docker exec dovsg-main bash -c "echo \$DISPLAY"`
5. Verify file permissions: `ls -la DovSG/` (should be owned by your user)
6. Restart containers: `docker compose restart dovsg`
7. Full rebuild (last resort): `./scripts/build --dovsg --no-cache`

## Next Steps
- Complete manual verification: See `MANUAL_VERIFICATION.md`
- Run full demo: `./scripts/demo`
- Development: Edit code in `DovSG/`, test with real-time logging commands
- Report issues: Link to GitHub issues (if applicable)

## Links
- Manual testing guide: [MANUAL_VERIFICATION.md](MANUAL_VERIFICATION.md)
- Original DovSG: [https://github.com/BJHYZJ/DovSG](https://github.com/BJHYZJ/DovSG)
- DovSG Paper: [arXiv:2410.11989](https://arxiv.org/abs/2410.11989)
```

**Sections to Remove/Consolidate**:
- Multi-machine deployment (move to advanced section or remove)
- Script descriptions (minimize, link to script --help)
- Version control tracking (remove, not relevant to setup)

---

### 3.2 `docker/MANUAL_VERIFICATION.md` - End-to-End Checks for DovSG

**Purpose**: Deterministic test matrix to validate DovSG installation and functionality

**Outline** (bullets only):

```markdown
# DovSG Docker Environment Manual Verification Guide

## Overview
- Purpose: Step-by-step validation of complete DovSG pipeline
- Prerequisite: Completed setup from `README.md`
- Estimated time: 45-60 minutes (first full run)

## Prerequisites Checklist
- [ ] Docker containers built and running (`docker compose ps`)
- [ ] Sample data downloaded to `DovSG/data_example/room1/`
- [ ] Model checkpoints downloaded (`ls DovSG/checkpoints/droid-slam/droid.pth`)
- [ ] X11 forwarding enabled (`xhost +local:docker`)
- [ ] File permissions correct (`ls -la DovSG/` shows your username)
- [ ] GPU access working (`docker exec dovsg-main nvidia-smi`) OR Mesa drivers installed

---

## Phase 1: Environment Verification

### Step 1.1: Verify Working Directory
**Command**:
```bash
cd docker/
pwd  # Expected: /path/to/4DSG/docker
ls   # Expected: docker-compose.yml, dockerfiles/, scripts/
```
**Pass Criteria**: Working directory correct

### Step 1.2: Check Container Status
**Command**:
```bash
./scripts/start --status
```
**Expected Output**:
```
Container Status:
===================
Containers are running:
NAME               IMAGE               COMMAND                SERVICE      CREATED        STATUS        PORTS
dovsg-droid-slam   docker-droid-slam   ...                    droid-slam   X hours ago    Up X hours
dovsg-main         docker-dovsg        ...                    dovsg        X hours ago    Up X hours    0.0.0.0:8888->8888/tcp
```
**Pass Criteria**: Both containers show "Up" status

### Step 1.3: Test Container Functionality
**Command**:
```bash
./scripts/start --test
```
**Expected Output**:
```
Testing containers...

Testing DovSG container:
Python 3.9.X
DovSG container working

Testing DROID-SLAM container:
Python 3.9.X
DROID-SLAM container working

Testing GPU access:
[GPU information should display]
GPU access working
```
**Pass Criteria**: All three tests pass, no errors

### Step 1.4: Verify X11 Forwarding
**Command**:
```bash
# Enable X11 (if not already done)
xhost +local:docker

# Test X11 connection
docker exec dovsg-main bash -c "echo \$DISPLAY"
# Expected output: :0

# Test simple GUI app
docker exec dovsg-main bash -c "DISPLAY=:0 xeyes"
```
**Expected Output**:
- DISPLAY variable set
- xeyes window appears on desktop (eyes follow mouse)
- Close window with Ctrl+C in terminal

**Pass Criteria**: GUI window appears on host desktop

### Step 1.5: Verify Sample Data Structure
**Command**:
```bash
ls -la ../DovSG/data_example/room1/
```
**Expected Output** (directories/files present):
```
rgb/         - Directory with .jpg files
depth/       - Directory with .npy files
mask/        - Directory with .npy files (if available)
point/       - Directory with .npy files (if available)
calibration/ - Directory (if available)
calib.txt    - Calibration file
metadata.json - Metadata file (if available)
```
**Pass Criteria**: At minimum `rgb/`, `depth/`, `calib.txt` exist

### Step 1.6: Verify Model Checkpoints
**Command**:
```bash
ls -la ../DovSG/checkpoints/
```
**Expected Output** (directories present):
```
droid-slam/                        - DROID-SLAM weights
GroundingDINO/                     - GroundingDINO config + weights
segment-anything-2/                - SAM2 weights
recognize_anything/                - RAM weights
bert-base-uncased/                 - BERT model (HuggingFace)
CLIP-ViT-H-14-laion2B-s32B-b79K/  - CLIP model (HuggingFace)
anygrasp/                          - AnyGrasp SDK (optional)
```
**Critical checkpoint**:
```bash
ls -lh ../DovSG/checkpoints/droid-slam/droid.pth
# Expected: ~150MB file
```
**Pass Criteria**: All core checkpoints present

---

## Phase 2: DROID-SLAM Pose Estimation

### Step 2.1: Test DROID-SLAM Help
**Command**:
```bash
docker exec dovsg-droid-slam bash -c "cd /app/DROID-SLAM && conda run -n droidenv python demo.py --help"
```
**Expected Output**: Help message with arguments (--imagedir, --calib, --weights, --buffer, etc.)
**Pass Criteria**: Help message displays without errors

### Step 2.2: Run DROID-SLAM Pose Estimation
**Command** (using DovSG pose estimation script):
```bash
# First-time setup: Apply DROID-SLAM trajectory_filler.py fix
docker exec dovsg-droid-slam sed -i 's/for (tstamp, image, intrinsic) in image_stream:/for (tstamp, image, _, intrinsic) in image_stream:/' /app/DROID-SLAM/droid_slam/trajectory_filler.py

# Run pose estimation
docker exec dovsg-droid-slam bash -c "cd /app && PYTHONPATH=/app/DROID-SLAM/droid_slam:/app/DROID-SLAM:\$PYTHONPATH conda run -n droidenv python dovsg/scripts/pose_estimation.py --datadir 'data_example/room1' --calib 'data_example/room1/calib.txt' --weights 'checkpoints/droid-slam/droid.pth' --stride=1 --buffer=256"
```
**Parameters Explained**:
- `--datadir`: Root directory containing `rgb/` subdirectory
- `--calib`: Camera calibration (fx, fy, cx, cy)
- `--stride=1`: Process every frame (use 2-4 for speed/memory tradeoff)
- `--buffer=256`: Memory buffer (128=4GB GPU, 256=8GB GPU, 512=12GB+ GPU)

**Expected Output**:
```
Processing frames...
[Progress bars showing frame processing]
Saved poses to: data_example/room1/poses_droidslam/
```
**Pass Criteria**:
- No errors during processing
- `poses_droidslam/` directory created with pose files

### Step 2.3: Verify DROID-SLAM Output
**Command**:
```bash
ls -la ../DovSG/data_example/room1/poses_droidslam/
```
**Expected Output**: Directory with pose files (timestamps.txt, poses.txt, or similar)
**Pass Criteria**: Pose files generated

---

## Phase 3: Point Cloud Visualization

### Step 3.1: Test Point Cloud Viewer
**Command**:
```bash
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/dovsg/scripts/show_pointcloud.py --tags room1 --pose_tags poses_droidslam"
```
**Expected Output**:
```
Loading RGB-D data...
[Progress messages]
Displaying point cloud...
```
**Expected Behavior**:
- Open3D window appears on desktop (1280x720 or similar)
- Colored 3D point cloud of room scene
- Interactive controls:
  - Left mouse drag: Rotate view
  - Right mouse drag: Pan view
  - Scroll wheel: Zoom in/out
  - Window should be responsive

**Pass Criteria**:
- GUI window appears
- Point cloud visible (colored 3D scene)
- Mouse controls work
- Close window to continue

---

## Phase 4: DovSG Preprocessing

### Step 4.1: Test DovSG Demo Help
**Command**:
```bash
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --help"
```
**Expected Output**: Help message showing all arguments including `--skip_task_planning`
**Pass Criteria**: Help displays with all flags

### Step 4.2: Run DovSG Full Preprocessing
**Command**:
```bash
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1 --preprocess --skip_task_planning"
```
**Expected Output Sequence**:
```
1. Pose estimation (or skipped if poses exist)
2. Floor transformation
   - RANSAC plane fitting
   - Coordinate transformation
3. ACE relocalization training
   - Dataset preparation
   - Training epochs
4. View dataset generation
   - Voxelization (1cm default)
   - RGB-D-Pose fusion
5. Semantic memory construction
   - RAM tagging
   - GroundingDINO detection
   - SAM2 segmentation
   - CLIP feature extraction
6. Instance construction
   - Multi-view fusion
   - Spatial/visual/text similarity
7. Scene graph generation
   - Relationship inference (on/belong/inside)
   - Graphviz PDF generation
8. LightGlue feature extraction
9. Interactive 3DSG viewer launch
```
**Expected Duration**: 15-30 minutes (varies by hardware)

**Expected GUI Windows** (in sequence):
1. **Point cloud viewer** (after floor transformation)
2. **View dataset viewer** (after voxelization)
3. **Interactive 3DSG viewer** (final, with keyboard controls)

**Pass Criteria**:
- Real-time output visible (not buffered)
- All 9 stages complete without crashes
- Three GUI windows appear
- Final viewer opens with keyboard controls active

### Step 4.3: Verify Preprocessing Artifacts
**Command**:
```bash
ls -la ../DovSG/data_example/room1/
```
**Expected Output** (new directories/files):
```
poses_droidslam/        - Camera poses (from Phase 2)
memory/                 - View dataset cache
ace/                    - ACE relocalization model
semantic_memory/        - Detection results (.pkl files)
instances/              - Instance segmentation
instance_scene_graph.pkl - 3DSG data structure
scene_graph.pdf         - Graphviz visualization (if Graphviz installed)
lightglue_features.pth  - Feature descriptors
```
**Pass Criteria**: All artifacts present

---

## Phase 5: Interactive 3DSG Viewer Validation

### Step 5.1: Expected Viewer Window
**Window Properties**:
- Title: "Open3D"
- Size: 1280x720 pixels
- Content: 3D point cloud with detected objects (or white background if mock detector)

### Step 5.2: Keyboard Controls Test Matrix

**CRITICAL UPDATE**: CLIP query key remapping
- **Original**: 'F' key
- **User's fix**: Changed to 'A' key in `visualize_instances.py:364`
- **Documentation**: Use 'A' key below

| Key | Function | Expected Behavior | Pass Criteria |
|-----|----------|-------------------|---------------|
| **B** | Toggle background point cloud | Background appears/disappears | Visibility changes |
| **C** | Color by semantic class | Objects colored by class (if detected) | Color change |
| **R** | Color by RGB appearance | Objects show natural colors | Color change to RGB |
| **A** | Color by CLIP similarity | Prompts for query, colors by similarity | Input prompt appears (or default "object") |
| **G** | Toggle scene graph relationships | Lines/connections between objects (if detected) | Graph edges visible/hidden |
| **I** | Color by instance ID | Each object gets unique color | Distinct colors per object |
| **O** | Toggle bounding boxes | 3D boxes around objects (if detected) | Boxes appear/disappear |
| **V** | Save view parameters | Saves current camera position | Console message confirms save |

**Testing Procedure**:
1. Open interactive viewer (from Step 4.2 or rerun)
2. Test each key sequentially
3. Verify visual response or console output
4. Document any non-responsive keys

**Pass Criteria**:
- All 8 keys respond (visual change or console message)
- Window remains stable (no crashes)
- 'A' key handles input (or defaults to "object" in non-interactive mode)

### Step 5.3: Mouse Controls Test

| Control | Expected Behavior | Pass Criteria |
|---------|-------------------|---------------|
| Left mouse drag | Rotate camera around scene | View rotates smoothly |
| Right mouse drag | Pan camera position | View translates |
| Scroll wheel | Zoom in/out | Scene scales |
| Window resize | Viewport adjusts | Content rescales |

**Pass Criteria**: All mouse controls responsive

---

## Phase 6: 3DSG-Only Workflow (Fast Iteration)

**Purpose**: Test 3DSG construction without full 15-30min preprocessing

**Prerequisites**:
- Phase 4 completed successfully (artifacts exist)
- Artifacts present: `poses_droidslam/`, `memory/`, `ace/`

### Step 6.1: Run 3DSG-Only Script
**Command**:
```bash
cd /home/cerlab/4DSG/docker
./scripts/run_3dsg_only.sh room1
```
**Expected Output**:
```
=== DovSG 3DSG-Only Pipeline ===
Tags: room1
Checking required artifacts...
✓ Found: poses_droidslam/
✓ Found: memory/
✓ All required artifacts present
✓ Container running

=== Running 3DSG Construction Pipeline ===
Loading view dataset...
Processing semantic memory...
Processing instances...
Constructing 3D scene graph...
Extracting LightGlue features...
Opening interactive 3DSG viewer...
Controls: B=background, C=class colors, R=RGB, A=CLIP, G=scene graph, I=instances, O=bboxes, V=save view
```
**Expected Duration**: 5-10 minutes (significantly faster than full preprocessing)

**Pass Criteria**:
- Artifact checks pass
- Pipeline runs without errors
- Interactive viewer opens with same controls as Phase 5

### Step 6.2: Alternative Direct Command
**Command**:
```bash
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1 --skip_task_planning"
```
**Note**: `--preprocess` flag omitted (assumes artifacts exist)

**Pass Criteria**: Same as Step 6.1

---

## Phase 7: Common Flags Validation

### Step 7.1: Test `--skip_task_planning` Flag
**Purpose**: Verify bypass of LLM task planning (no OpenAI API key required)

**Command**:
```bash
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1 --skip_task_planning"
```
**Expected Behavior**:
- No OpenAI API key errors
- Skips task decomposition and execution
- Proceeds directly to visualization

**Pass Criteria**: No API key errors, visualization opens

### Step 7.2: Test `--debug` Flag
**Command**:
```bash
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1 --debug --skip_task_planning"
```
**Expected Behavior**: More verbose console output, additional debug visualizations
**Pass Criteria**: Increased logging verbosity

---

## Phase 8: Performance Validation

### Step 8.1: GPU Memory Usage Check
**Command** (run during demo execution):
```bash
docker exec dovsg-main nvidia-smi
```
**Expected Output**:
```
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|    0   N/A  N/A      XXXX      C   python                           5-7GB  |
+-----------------------------------------------------------------------------+
```
**Pass Criteria**:
- GPU memory usage reasonable (not 100% or OOM)
- Python process visible
- Memory usage: ~5-7GB VRAM (typical for full pipeline)

### Step 8.2: Timing Benchmarks

| Operation | Expected Duration | Your Result | Pass/Fail |
|-----------|-------------------|-------------|-----------|
| DROID-SLAM pose estimation (~739 frames, stride=1) | 2-5 minutes | | |
| Full preprocessing (Phase 4.2) | 15-30 minutes | | |
| 3DSG-only pipeline (Phase 6.1) | 5-10 minutes | | |
| Interactive viewer responsiveness | Real-time (60fps) | | |

**Note**: Timing varies by hardware (RTX 4090 reference benchmarks above)

---

## Phase 9: Error Handling & Edge Cases

### Step 9.1: Test Empty Objects Handling
**Scenario**: Mock detector returns zero detections (current default)

**Expected Behavior**:
- No crashes from `np.concatenate()` on empty arrays
- Interactive viewer shows white background (press 'B' for background points)
- Console message: "No objects detected" (various locations)

**Verification Command**:
```bash
# Run full pipeline (mock detector active)
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1 --skip_task_planning"
```
**Pass Criteria**:
- No ValueError crashes
- Viewer opens (even with zero objects)
- Background point cloud visible when 'B' pressed

### Step 9.2: Test CLIP Query in Non-Interactive Mode
**Scenario**: 'A' key pressed when `input()` unavailable (Docker exec)

**Expected Behavior**:
```
Enter your query: Interactive input not available. Using default query: 'object'
[CLIP similarity computation with default query]
```
**Pass Criteria**: No EOFError crash, defaults to "object" query

### Step 9.3: Test Container Restart After File Edit
**Scenario**: Edit `demo.py` directly and run without restart

**Steps**:
```bash
# 1. Edit demo.py (add debug print)
echo 'print("TEST EDIT")' >> ../DovSG/demo.py

# 2. Run WITHOUT restart
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --help | head -5"
# Expected: May NOT show "TEST EDIT"

# 3. Restart container
docker compose restart dovsg
sleep 5

# 4. Run AFTER restart
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --help | head -5"
# Expected: SHOULD show "TEST EDIT"

# 5. Cleanup
git checkout ../DovSG/demo.py  # Restore original
docker compose restart dovsg
```
**Pass Criteria**: Edit visible after restart, not before

---

## Success Criteria Summary

### Environment (Phase 1)
- [x] Containers running
- [x] GPU access functional (or Mesa fallback working)
- [x] X11 forwarding enabled (GUI windows appear on desktop)
- [x] Sample data and checkpoints present
- [x] File permissions correct

### DROID-SLAM (Phase 2)
- [x] Pose estimation completes without errors
- [x] `poses_droidslam/` directory created with pose files
- [x] Processing time reasonable (2-5 minutes for ~739 frames)

### Visualization (Phase 3)
- [x] Point cloud viewer opens
- [x] 3D scene visible and interactive
- [x] Mouse controls responsive

### Preprocessing (Phase 4)
- [x] All 9 pipeline stages complete
- [x] Real-time output visible (not buffered)
- [x] Three GUI windows appear in sequence
- [x] All artifacts generated (`memory/`, `semantic_memory/`, `instances/`, etc.)
- [x] No crashes from empty objects or device mismatches

### Interactive Viewer (Phase 5)
- [x] Final viewer opens (1280x720 window)
- [x] All 8 keyboard controls respond ('A' for CLIP query)
- [x] Mouse controls work (rotate, pan, zoom)
- [x] Window stable (no crashes)

### 3DSG-Only Workflow (Phase 6)
- [x] Fast iteration works (5-10 minutes vs 15-30 minutes)
- [x] Artifact checks pass
- [x] Same visualization quality as full preprocessing

### Flags & Configuration (Phase 7)
- [x] `--skip_task_planning` prevents API key errors
- [x] `--debug` increases verbosity
- [x] Real-time logging pattern works (`python -u`)

### Performance (Phase 8)
- [x] GPU memory usage reasonable (~5-7GB)
- [x] Timing within expected ranges
- [x] No OOM errors

### Edge Cases (Phase 9)
- [x] Empty objects handled gracefully
- [x] CLIP query defaults work in non-interactive mode
- [x] Container restart syncs volume-mounted changes

---

## Expected File Outputs After Full Run

**Command to verify**:
```bash
ls -la ../DovSG/data_example/room1/
```
**Expected structure**:
```
data_example/room1/
├── rgb/                          # Input: RGB images
├── depth/                        # Input: Depth images
├── calib.txt                     # Input: Camera calibration
├── poses_droidslam/              # Output: DROID-SLAM poses
├── memory/                       # Output: View dataset cache
├── ace/                          # Output: ACE relocalization model
├── semantic_memory/              # Output: Detection results (.pkl)
├── instances/                    # Output: Instance segmentation
├── instance_scene_graph.pkl      # Output: 3DSG data structure
├── scene_graph.pdf               # Output: Graphviz visualization (optional)
└── lightglue_features.pth        # Output: LightGlue features
```

---

## Troubleshooting Reference

**Quick diagnostics**:
```bash
# 1. Container status
./scripts/start --status

# 2. Container tests
./scripts/start --test

# 3. GPU check
docker exec dovsg-main nvidia-smi

# 4. X11 check
docker exec dovsg-main bash -c "echo \$DISPLAY"
xhost +local:docker

# 5. File permissions
ls -la ../DovSG/ | head -10  # Should show your username

# 6. Restart containers
docker compose restart dovsg

# 7. Full rebuild (last resort)
./scripts/build --dovsg --no-cache
```

**Common errors and solutions**: See `README.md` "Common Pitfalls & Solutions" section

---

## Next Steps After Verification

1. **Development**: Edit code in `DovSG/dovsg/`, restart container if needed
2. **Custom scenes**: Add new data to `data_example/YOUR_SCENE/`, run with `--tags YOUR_SCENE`
3. **Real robot**: See original DovSG README for ROS integration (hardcode/ directory)
4. **Performance tuning**: Adjust buffer sizes, stride, resolution parameters

---

## Appendix: Command Reference Card

**Most common commands** (copy-paste ready):

```bash
# Setup (first time)
cd docker && ./scripts/setup

# Enable X11
xhost +local:docker

# Full preprocessing
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1 --preprocess --skip_task_planning"

# 3DSG only (fast)
./scripts/run_3dsg_only.sh room1

# Point cloud viewer
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/dovsg/scripts/show_pointcloud.py --tags room1 --pose_tags poses_droidslam"

# Container management
./scripts/start           # Start
./scripts/start --stop    # Stop
./scripts/start --test    # Test
docker compose restart dovsg  # Restart after file edits

# Interactive shell
docker exec -it dovsg-main bash
# Inside: conda activate dovsg
```

**Keyboard controls in interactive viewer**:
```
B - Background toggle
C - Class colors
R - RGB colors
A - CLIP similarity (query prompt)
G - Scene graph (relationships)
I - Instance colors
O - Bounding boxes
V - Save view
```
```

**Sections to Remove/Consolidate**:
- Redundant X11 setup (merge into Phase 1)
- Duplicate DROID-SLAM commands (consolidate into Phase 2)
- Obsolete timing estimates (update with current benchmarks)
- Deprecated script references (update to canonical scripts)

---

## 4. Script Consolidation Plan

### 4.1 Current State (9 scripts)
1. `setup` - Complete environment setup
2. `build` - Build containers
3. `start` - Start/stop/status containers
4. `demo` - Interactive demo runner
5. `download` - Download checkpoints
6. `init-dirs` - Create directories
7. `common.sh` - Shared functions
8. `run_3dsg_only.sh` - 3DSG-only execution

### 4.2 Target State (5 canonical + 2 utilities)

**Canonical Entry Scripts** (user-facing):
1. **`setup`** - First-time environment setup
2. **`start`** - Container lifecycle management
3. **`run_demo.sh`** - Demo execution (replaces `demo`)
4. **`run_3dsg_only.sh`** - 3DSG-only workflow
5. **`verify.sh`** - Automated verification (NEW)

**Utility Scripts** (called by canonical scripts):
6. **`common.sh`** - Shared bash functions (library)
7. **Internal functions** - Merge `build`, `download`, `init-dirs` into `setup`

### 4.3 Script Mapping Table

| Old Script(s) | New Canonical Script | Flags/Args | Changes Required | Rationale |
|---------------|---------------------|------------|------------------|-----------|
| `setup` | `setup` (KEEP) | None (automated) | Add X11 validation, real-time logging examples | Primary entry point, consolidate sub-scripts |
| `build` | `setup` (MERGE) | Call internally | Merge into setup as function | Only needed during setup or rebuild |
| `download` | `setup` (MERGE) | Call internally | Merge into setup as function | Only needed during setup |
| `init-dirs` | `setup` (MERGE) | Call internally | Merge into setup as function | Simple utility, inline into setup |
| `start` | `start` (KEEP) | `--start\|--stop\|--restart\|--status\|--test` | Add X11 connection test to `--test` | Container lifecycle, already well-designed |
| `demo` | `run_demo.sh` (RENAME+EDIT) | `--full\|--preprocess\|--3dsg-only\|--help` | Add `--skip_task_planning`, real-time logging, remove interactive menu | Streamlined demo execution |
| `run_3dsg_only.sh` | `run_3dsg_only.sh` (KEEP) | `[TAGS]` (positional) | Add `--skip_task_planning`, real-time logging | Unique fast workflow |
| `common.sh` | `common.sh` (KEEP) | N/A (library) | No changes | Well-designed shared functions |
| N/A (NEW) | `verify.sh` (CREATE) | `--quick\|--full` | Automate MANUAL_VERIFICATION tests | Deterministic testing |

### 4.4 Standard Flag Grammar

**Consistent flag patterns across all scripts**:

| Flag | Purpose | Example | Used By |
|------|---------|---------|---------|
| `-h, --help` | Show help and exit | `./scripts/setup --help` | All scripts |
| `--dry-run` | Show what would be done without executing | `./scripts/setup --dry-run` | `setup`, `run_demo.sh` |
| `--skip-X` | Skip specific step | `--skip-task-planning`, `--skip-build` | `setup`, `run_demo.sh` |
| `--quick` | Fast minimal checks | `./scripts/verify.sh --quick` | `verify.sh` |
| `--full` | Complete operation | `./scripts/verify.sh --full` | `verify.sh`, `run_demo.sh` |
| `--tags SCENE` | Scene identifier | `--tags room1` | `run_demo.sh`, `run_3dsg_only.sh` |

**Environment variable mapping**:
```bash
# Standard env vars (all scripts detect these)
DISPLAY              # X11 display (default: :0)
DOVSG_DATA_DIR       # Override data location (default: ../DovSG/data_example)
DOVSG_CHECKPOINTS    # Override checkpoint location (default: ../DovSG/checkpoints)
DOVSG_SKIP_GPU_CHECK # Skip GPU validation (for Mesa/CPU testing)
```

### 4.5 Preflight Checks (Standard Pattern)

**Every script starts with** (use `common.sh` functions):
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

check_directory          # Verify working directory
check_docker             # Verify Docker installed
check_dry_run_flag "$@"  # Parse --dry-run early

# Script-specific checks
if [ "$SCRIPT" = "setup" ]; then
    check_nvidia_docker || warn_mesa_fallback
fi
```

**Dry-run pattern**:
```bash
run_command() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would execute: $@"
    else
        "$@"
    fi
}
```

### 4.6 Detailed Script Plans

#### 4.6.1 `setup` (Canonical Entry #1)

**Current state**: Calls `init-dirs`, `download`, `build` as separate scripts
**Target state**: Self-contained setup with all logic inlined

**New structure**:
```bash
#!/bin/bash
# setup - Complete DovSG environment setup

source common.sh
check_directory
check_docker

echo "DovSG Setup Wizard"

# Parse flags
SKIP_BUILD=false
SKIP_DOWNLOAD=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build) SKIP_BUILD=true; shift ;;
        --skip-download) SKIP_DOWNLOAD=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help) show_setup_help; exit 0 ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done

# Step 1: GPU detection and path selection
echo "Detecting GPU..."
if check_nvidia_docker; then
    echo "✓ NVIDIA GPU detected - using GPU acceleration"
    GPU_PATH="nvidia"
else
    echo "⚠ No NVIDIA GPU - using Mesa software rendering"
    read -p "Continue with CPU rendering? (y/N): " -r
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
    GPU_PATH="mesa"
fi

# Step 2: Create directories (inline init-dirs logic)
echo "Creating directory structure..."
run_command mkdir -p ../DovSG/{data_example,checkpoints/{droid-slam,GroundingDINO,segment-anything-2,recognize_anything,bert-base-uncased,CLIP-ViT-H-14-laion2B-s32B-b79K,anygrasp}}
run_command mkdir -p ../shared_data

# Step 3: Download checkpoints (inline download logic)
if [ "$SKIP_DOWNLOAD" = false ]; then
    echo "Downloading checkpoints (~10GB)..."
    # Inline checkpoint download logic from download script
    run_command download_droid_slam
    run_command download_groundingdino
    # ... etc
else
    echo "Skipping checkpoint download (--skip-download)"
fi

# Step 4: Build containers (inline build logic)
if [ "$SKIP_BUILD" = false ]; then
    echo "Building Docker containers (30-60 minutes)..."
    if [ "$GPU_PATH" = "nvidia" ]; then
        run_command docker compose build
    else
        run_command docker compose -f docker-compose.yml -f compose.mesa.yml build
    fi
else
    echo "Skipping container build (--skip-build)"
fi

# Step 5: X11 setup guide
echo "X11 GUI Setup:"
echo "Run this command on your host:"
echo "  xhost +local:docker"
echo "Verify with:"
echo "  echo \$DISPLAY  # Should show :0"

# Step 6: Start containers
echo "Starting containers..."
run_command ./start

# Step 7: Validation
echo "Running quick validation..."
run_command ./start --test

# Step 8: Manual data download reminder
echo ""
echo "⚠ Manual Step Required:"
echo "Download sample data from:"
echo "  https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x"
echo "Extract to: ../DovSG/data_example/room1/"
echo ""
echo "✓ Setup complete! Next steps:"
echo "  1. Download sample data (see above)"
echo "  2. Run verification: ./scripts/verify.sh --quick"
echo "  3. Run demo: ./scripts/run_demo.sh --help"
```

**Changes from current**:
- Inline `init-dirs`, `download`, `build` logic
- Add GPU detection and Mesa fallback path
- Add `--dry-run` support
- Add X11 setup instructions
- Remove separate script calls

---

#### 4.6.2 `start` (Canonical Entry #2)

**Current state**: Already well-designed
**Target state**: Add X11 connection test

**Changes needed**:
```bash
# In common.sh, add new function:
check_x11_forwarding() {
    echo "Testing X11 forwarding..."
    if docker exec -T dovsg bash -c "echo \$DISPLAY" | grep -q ":"; then
        echo "✓ DISPLAY variable set"
        if docker exec dovsg bash -c "DISPLAY=:0 timeout 2 xeyes" 2>/dev/null; then
            echo "✓ X11 connection working"
            return 0
        else
            echo "⚠ X11 connection failed. Run: xhost +local:docker"
            return 1
        fi
    else
        echo "⚠ DISPLAY not set"
        return 1
    fi
}

# In start script, modify --test action:
"test")
    check_containers_built
    test_containers
    check_x11_forwarding  # NEW
    ;;
```

**No other changes needed** - `start` script already has good flag design

---

#### 4.6.3 `run_demo.sh` (Canonical Entry #3) - Replaces `demo`

**Current state**: Interactive menu-based
**Target state**: Flag-based with non-interactive mode

**New structure**:
```bash
#!/bin/bash
# run_demo.sh - DovSG demo execution

source common.sh
check_directory
check_containers_built

# Defaults
TAGS="room1"
MODE="full"  # full, preprocess, 3dsg-only
SKIP_TASK_PLANNING=true  # Default to true (no API key needed)
DEBUG=false
DRY_RUN=false

# Parse flags
while [[ $# -gt 0 ]]; do
    case $1 in
        --tags) TAGS="$2"; shift 2 ;;
        --full) MODE="full"; shift ;;
        --preprocess) MODE="preprocess"; shift ;;
        --3dsg-only) MODE="3dsg-only"; shift ;;
        --with-task-planning) SKIP_TASK_PLANNING=false; shift ;;
        --debug) DEBUG=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help) show_demo_help; exit 0 ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done

# Build command
CMD="docker exec dovsg-main bash -c \"source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags $TAGS"

case $MODE in
    "full")
        CMD="$CMD --preprocess"
        [ "$DEBUG" = true ] && CMD="$CMD --debug"
        ;;
    "preprocess")
        CMD="$CMD --preprocess"
        ;;
    "3dsg-only")
        # No --preprocess flag
        ;;
esac

# Always add --skip_task_planning unless explicitly requested
[ "$SKIP_TASK_PLANNING" = true ] && CMD="$CMD --skip_task_planning"

CMD="$CMD\""  # Close quote

# Execute or dry-run
if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would execute:"
    echo "$CMD"
else
    echo "Running DovSG demo..."
    echo "Mode: $MODE | Tags: $TAGS | Task Planning: $([ "$SKIP_TASK_PLANNING" = true ] && echo "Skipped" || echo "Enabled")"
    eval $CMD
fi
```

**Help output**:
```
Usage: ./scripts/run_demo.sh [options]

Options:
  --tags SCENE            Scene identifier (default: room1)
  --full                  Full pipeline with preprocessing (default)
  --preprocess            Preprocessing only (no visualization)
  --3dsg-only             Skip preprocessing, assume artifacts exist
  --with-task-planning    Enable LLM task planning (requires OpenAI API key)
  --debug                 Enable debug mode
  --dry-run               Show command without executing
  -h, --help              Show this help

Examples:
  ./scripts/run_demo.sh --tags room1 --preprocess
  ./scripts/run_demo.sh --tags room1 --3dsg-only
  ./scripts/run_demo.sh --tags room1 --full --with-task-planning

Default: Full pipeline with task planning SKIPPED (no API key needed)
```

**Changes from current `demo`**:
- Remove interactive menu (use flags instead)
- Default to `--skip_task_planning` (no API key required)
- Use real-time logging pattern (`python -u`)
- Add `--dry-run` support
- Consistent with other script flag design

---

#### 4.6.4 `run_3dsg_only.sh` (Canonical Entry #4)

**Current state**: Good structure, needs minor updates
**Target state**: Add `--skip_task_planning` and real-time logging

**Changes needed**:
```bash
# Line 110: Update command to use real-time logging and skip task planning
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/3dsg_only.py \"$TAGS\" --skip_task_planning"
```

**No major restructuring needed** - already follows best practices

---

#### 4.6.5 `verify.sh` (Canonical Entry #5) - NEW

**Purpose**: Automate tests from `MANUAL_VERIFICATION.md`

**Structure**:
```bash
#!/bin/bash
# verify.sh - Automated verification tests for DovSG environment

source common.sh
check_directory

# Modes
MODE="quick"  # quick, full

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick) MODE="quick"; shift ;;
        --full) MODE="full"; shift ;;
        -h|--help) show_verify_help; exit 0 ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done

echo "DovSG Verification (Mode: $MODE)"
echo "================================"

# Phase 1: Environment (always run)
echo "Phase 1: Environment Verification"
run_test "Container status" "./start --status"
run_test "Container functionality" "./start --test"
run_test "Sample data structure" "ls ../DovSG/data_example/room1/{rgb,depth,calib.txt}"
run_test "Checkpoints present" "ls ../DovSG/checkpoints/droid-slam/droid.pth"

# Phase 2: DROID-SLAM (quick mode: skip, full mode: run)
if [ "$MODE" = "full" ]; then
    echo "Phase 2: DROID-SLAM Pose Estimation"
    run_test "DROID-SLAM help" "docker exec dovsg-droid-slam bash -c 'cd /app/DROID-SLAM && conda run -n droidenv python demo.py --help'"
    # Note: Actual pose estimation takes 2-5 minutes, prompt user
    echo "Run full pose estimation? (y/N)"
    read -r reply
    if [[ $reply =~ ^[Yy]$ ]]; then
        run_test "Pose estimation" "..."
    fi
fi

# Phase 3: Point Cloud Visualization (quick: skip, full: run)
if [ "$MODE" = "full" ]; then
    echo "Phase 3: Point Cloud Visualization"
    echo "Manual test: GUI window should appear"
    run_test "Point cloud viewer" "docker exec dovsg-main bash -c '...'"
fi

# Phase 4: DovSG Preprocessing (quick: help only, full: run)
echo "Phase 4: DovSG Demo"
run_test "Demo help" "docker exec dovsg-main bash -c 'source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --help'"

if [ "$MODE" = "full" ]; then
    echo "Run full preprocessing? (15-30 minutes) (y/N)"
    read -r reply
    if [[ $reply =~ ^[Yy]$ ]]; then
        run_test "Full preprocessing" "./run_demo.sh --preprocess"
    fi
fi

# Summary
echo ""
echo "Verification Summary:"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"

[ $TESTS_FAILED -eq 0 ] && echo "✓ All tests passed!" || echo "⚠ Some tests failed"
```

**Test helper function** (add to `common.sh`):
```bash
# Test tracking
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing: $test_name... "

    if eval "$test_command" > /dev/null 2>&1; then
        echo "✓ PASS"
        ((TESTS_PASSED++))
    else
        echo "✗ FAIL"
        ((TESTS_FAILED++))
    fi
}
```

---

### 4.7 Script Consolidation Summary

**Before** (9 files):
- `setup`, `build`, `start`, `demo`, `download`, `init-dirs`, `common.sh`, `run_3dsg_only.sh`, (no verification automation)

**After** (7 files total = 5 canonical + 2 utilities):
- **Canonical**: `setup`, `start`, `run_demo.sh`, `run_3dsg_only.sh`, `verify.sh`
- **Utilities**: `common.sh`, (build/download/init-dirs merged into setup)

**Reduction**: 9 → 7 files, clearer responsibility separation

---

## 5. Compose & Env Standardization

### 5.1 Current State
- Single `docker-compose.yml` with X11 and GPU configured
- No `.env` file (hardcoded defaults)
- No override mechanism for custom configs

### 5.2 Target State

**Files**:
1. **`docker/docker-compose.yml`** - Primary compose file (KEEP, add inline comments)
2. **`docker/.env.example`** - Template for optional env var overrides (CREATE)
3. **`docker/compose.override.example.yml`** - Template for custom GPU configs (CREATE)

### 5.3 `docker-compose.yml` Enhancements

**Add inline comments**:
```yaml
services:
  dovsg:
    environment:
      # X11 GUI forwarding (required for Open3D visualization)
      - DISPLAY=${DISPLAY:-:0}

      # Real-time output (prevents buffering until crash)
      - PYTHONUNBUFFERED=1

      # GPU access (graphics capability required for OpenGL)
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute

    volumes:
      # X11 socket for GUI windows on host desktop
      - /tmp/.X11-unix:/tmp/.X11-unix:rw

      # Live code editing (changes reflect without rebuild)
      - ../DovSG/dovsg:/app/dovsg
      - ../DovSG/demo.py:/app/demo.py
```

**No structural changes needed** - current compose file is well-designed

### 5.4 `.env.example` (NEW)

**Purpose**: Template for optional environment variable overrides

**Content**:
```bash
# DovSG Docker Environment Variables
# Copy this file to .env and customize as needed

# X11 Display (default: :0)
# Change if using custom display or remote X server
#DISPLAY=:1

# Data directories (default: relative paths)
# Override for custom data locations
#DOVSG_DATA_DIR=/custom/path/to/data
#DOVSG_CHECKPOINTS_DIR=/custom/path/to/checkpoints
#DOVSG_SHARED_DATA_DIR=/custom/path/to/shared

# GPU Configuration (default: all GPUs)
# Restrict to specific GPU(s)
#NVIDIA_VISIBLE_DEVICES=0
#CUDA_VISIBLE_DEVICES=0

# Wayland Compatibility (default: unset)
# Uncomment for Wayland systems with XWayland
#WAYLAND_DISPLAY=
#XDG_RUNTIME_DIR=/run/user/1000

# Mesa Software Rendering (default: disabled)
# Uncomment to force software rendering (no NVIDIA GPU)
#LIBGL_ALWAYS_SOFTWARE=1
#MESA_GL_VERSION_OVERRIDE=3.3

# Python Configuration (default: unbuffered)
# Already set in docker-compose.yml, override here if needed
#PYTHONUNBUFFERED=1
```

**Usage** (document in README.md):
```bash
# Optional: Create .env file for custom settings
cp .env.example .env
# Edit .env with your preferences
nano .env
```

### 5.5 `compose.override.example.yml` (NEW)

**Purpose**: Template for GPU configuration variants (NVIDIA vs Mesa)

**Content**:
```yaml
# DovSG Docker Compose Override Examples
# Copy sections to compose.override.yml for custom GPU configs

# ============================================
# Example 1: NVIDIA GPU with X11 (default)
# ============================================
# This is already configured in docker-compose.yml
# No override needed

# ============================================
# Example 2: Mesa Software Rendering (no GPU)
# ============================================
# Use this if you don't have NVIDIA GPU
# Copy to: compose.override.yml

version: '3.8'
services:
  dovsg:
    deploy:
      resources:
        reservations:
          devices: []  # Remove GPU reservation
    environment:
      # Override GPU capabilities
      - NVIDIA_VISIBLE_DEVICES=
      - NVIDIA_DRIVER_CAPABILITIES=
      # Enable Mesa software rendering
      - LIBGL_ALWAYS_SOFTWARE=1
      - MESA_GL_VERSION_OVERRIDE=3.3

# ============================================
# Example 3: Wayland with XWayland
# ============================================
# Use this for Ubuntu 22.04+ with Wayland

version: '3.8'
services:
  dovsg:
    environment:
      # Wayland compatibility
      - WAYLAND_DISPLAY=
      - XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}
      - QT_QPA_PLATFORM=xcb  # Force Qt to use X11
    volumes:
      # Add Wayland socket if needed
      - ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}

# ============================================
# Example 4: Specific GPU Selection
# ============================================
# Use this to restrict to specific GPU(s)

version: '3.8'
services:
  dovsg:
    environment:
      - NVIDIA_VISIBLE_DEVICES=0  # GPU 0 only
      - CUDA_VISIBLE_DEVICES=0
```

**Usage** (document in README.md):
```bash
# Optional: Create override for custom GPU config
cp compose.override.example.yml compose.override.yml
# Edit compose.override.yml with your GPU variant
nano compose.override.yml
# Restart containers
docker compose down && docker compose up -d
```

### 5.6 How README and MANUAL_VERIFICATION Reference These

**In `README.md`**:

**Section: "Environment Variables Reference"**:
```markdown
## Environment Variables Reference

DovSG uses these environment variables configured in `docker-compose.yml`:

| Variable | Default | Purpose |
|----------|---------|---------|
| `DISPLAY` | `:0` | X11 display for GUI windows |
| `PYTHONUNBUFFERED` | `1` | Real-time output (no buffering) |
| `NVIDIA_VISIBLE_DEVICES` | `all` | GPU access |
| `NVIDIA_DRIVER_CAPABILITIES` | `graphics,utility,compute` | GPU + OpenGL rendering |

**Optional Overrides**: Create `.env` file from `.env.example` template:
- Custom display: `DISPLAY=:1`
- Custom data paths: `DOVSG_DATA_DIR=/custom/path`
- GPU selection: `NVIDIA_VISIBLE_DEVICES=0`

See `.env.example` for all available overrides.
```

**Section: "GPU Configuration Variants"**:
```markdown
## GPU Configuration Variants

**NVIDIA GPU** (default): Already configured in `docker-compose.yml`

**Mesa Software Rendering** (no NVIDIA GPU):
1. Copy override template: `cp compose.override.example.yml compose.override.yml`
2. Uncomment "Mesa Software Rendering" section
3. Restart: `docker compose down && docker compose up -d`
4. Expect slower visualization (CPU rendering)

**Wayland Systems** (Ubuntu 22.04+):
1. Enable XWayland: `export WAYLAND_DISPLAY=""`
2. Use compose override for Wayland compatibility (see `compose.override.example.yml`)

See `compose.override.example.yml` for all GPU variant configurations.
```

**In `MANUAL_VERIFICATION.md`**:

**Phase 1, Step 1.4: Verify X11 Forwarding**:
```markdown
### Step 1.4: Verify X11 Forwarding

**Standard X11 systems**:
```bash
xhost +local:docker
docker exec dovsg-main bash -c "echo \$DISPLAY"
# Expected: :0
```

**Wayland systems** (if X11 test fails):
```bash
export WAYLAND_DISPLAY=""
xhost +SI:localuser:root
```

**Custom display** (if using non-default):
```bash
# Create .env file
echo "DISPLAY=:1" > .env
docker compose restart dovsg
```

See `README.md` "Environment Variables" for full configuration options.
```

---

## 6. Deprecation & Archival Strategy

### 6.1 Files to Archive

| File | Archive Location | Reason |
|------|------------------|--------|
| `docker/COMPLETE_X11_GUI_TESTING.md` | `docker/_archive/X11_GUI_TESTING_20250126.md` | Content merged into `MANUAL_VERIFICATION.md` Phase 1 & 6 |
| `docker/3dsg_only_plan.md` | `docker/_archive/3DSG_ONLY_PLAN_20250126.md` | Content merged into `MANUAL_VERIFICATION.md` Phase 6 |
| `docker/scripts/demo` (old interactive version) | `docker/scripts/_archive/demo_interactive_20250126` | Replaced by `run_demo.sh` with flag-based interface |

### 6.2 Deprecation Banner Template

**Add to top of archived files**:
```markdown
---
**DEPRECATED**: This document has been superseded.

**Replacement**: See `MANUAL_VERIFICATION.md` for current testing procedures

**Deprecation Date**: 2025-01-26

**Reason**: Content consolidated into unified testing guide

**Archived Version**: This file preserved for historical reference only

**Migration Path**:
- X11 GUI testing → `MANUAL_VERIFICATION.md` Phase 1 (Environment Verification)
- 3DSG keyboard controls → `MANUAL_VERIFICATION.md` Phase 5 (Interactive Viewer)
- Expected windows → `MANUAL_VERIFICATION.md` Phase 4 (Preprocessing)

If you need this specific content, refer to the sections above.
---
```

### 6.3 Archive Directory Structure

**Create directories**:
```bash
mkdir -p docker/_archive/docs
mkdir -p docker/scripts/_archive
```

**Archived structure**:
```
docker/
├── _archive/
│   ├── README_DEPRECATION.md  # Index of all archived files
│   ├── X11_GUI_TESTING_20250126.md
│   ├── 3DSG_ONLY_PLAN_20250126.md
│   └── docs/  # Future archived docs
└── scripts/
    └── _archive/
        └── demo_interactive_20250126  # Old demo script
```

**`_archive/README_DEPRECATION.md`** (index file):
```markdown
# Archived Documentation Index

This directory contains deprecated documentation and scripts preserved for historical reference.

## Deprecation Policy
- Files moved here are superseded by current documentation
- Each file includes a deprecation banner with migration path
- Files are timestamped (YYYYMMDD format)
- Do NOT use archived files for new work

## Archived Files

| File | Deprecation Date | Replacement | Reason |
|------|------------------|-------------|--------|
| `X11_GUI_TESTING_20250126.md` | 2025-01-26 | `MANUAL_VERIFICATION.md` Phase 1 & 6 | Content merged into unified testing guide |
| `3DSG_ONLY_PLAN_20250126.md` | 2025-01-26 | `MANUAL_VERIFICATION.md` Phase 6 | Content merged, keyboard controls updated |
| `scripts/_archive/demo_interactive_20250126` | 2025-01-26 | `scripts/run_demo.sh` | Flag-based interface replaced interactive menu |

## Migration Paths

**X11 GUI Testing** → `MANUAL_VERIFICATION.md` Phases 1 & 6
**3DSG Execution** → `MANUAL_VERIFICATION.md` Phase 6 or `scripts/run_3dsg_only.sh`
**Demo Execution** → `scripts/run_demo.sh --help`

## Accessing Current Documentation
- New device setup: `docker/README.md`
- Testing procedures: `docker/MANUAL_VERIFICATION.md`
- Script usage: `docker/scripts/SCRIPT_NAME --help`
```

### 6.4 Cross-Links from Live Docs

**Only when absolutely necessary** (avoid clutter):

**In `README.md` (Troubleshooting section)**:
```markdown
## Historical References

For historical installation methods (native conda, pre-Docker):
- See archived docs: `_archive/README_DEPRECATION.md`
- Original DovSG docs: `DovSG/docs/install_dovsg.md` (upstream)
```

**In `MANUAL_VERIFICATION.md` (Appendix)**:
```markdown
## Appendix: Historical Testing Procedures

Previous standalone test guides have been consolidated into this document:
- X11 GUI testing (Sep 2024): See Phase 1 & 6 above
- 3DSG-only execution (Sep 2024): See Phase 6 above

Archived versions available at: `_archive/README_DEPRECATION.md`
```

**Minimal cross-linking principle**: Only link to archive index, never deep-link to specific archived files

---

## 7. Validation & Acceptance Checklist

### 7.1 "New Device Setup" Validation

**Test on fresh Ubuntu installation**:
- [ ] Clone repository
- [ ] Run `cd docker && ./scripts/setup`
- [ ] Follow README.md only (no external resources)
- [ ] Complete setup without errors
- [ ] Run `./scripts/start --test` - all tests pass
- [ ] Download sample data from Google Drive
- [ ] Run `./scripts/run_demo.sh --preprocess`
- [ ] Verify GUI windows appear
- [ ] Complete in <2 hours (excluding download time)

**Acceptance criteria**:
- [ ] README.md is self-contained (no missing steps)
- [ ] All commands copy-paste without modification
- [ ] X11 setup documented with verification steps
- [ ] GPU and Mesa paths clearly explained
- [ ] Common pitfalls section addresses actual errors encountered

### 7.2 "Manual Verification" Validation

**Run all 9 phases**:
- [ ] Phase 1: Environment verification (5 steps)
- [ ] Phase 2: DROID-SLAM pose estimation
- [ ] Phase 3: Point cloud visualization
- [ ] Phase 4: DovSG preprocessing (15-30 min)
- [ ] Phase 5: Interactive viewer controls (8 keys)
- [ ] Phase 6: 3DSG-only workflow (5-10 min)
- [ ] Phase 7: Common flags (`--skip_task_planning`, `--debug`)
- [ ] Phase 8: Performance benchmarks
- [ ] Phase 9: Edge cases (empty objects, CLIP query, container restart)

**Acceptance criteria**:
- [ ] All phases have clear pass/fail criteria
- [ ] Expected outputs specified for each command
- [ ] Timing estimates accurate (±20% tolerance)
- [ ] Keyboard controls table updated (CLIP key = 'A')
- [ ] All commands use real-time logging pattern (`python -u`)
- [ ] `--skip_task_planning` flag present in all demo commands

### 7.3 Script Entry Points Validation

**Test all 5 canonical scripts**:
```bash
# 1. Setup
./scripts/setup --dry-run
./scripts/setup --help

# 2. Start
./scripts/start --status
./scripts/start --test

# 3. Demo
./scripts/run_demo.sh --help
./scripts/run_demo.sh --tags room1 --preprocess --dry-run

# 4. 3DSG-only
./scripts/run_3dsg_only.sh --help
./scripts/run_3dsg_only.sh room1

# 5. Verify
./scripts/verify.sh --quick
./scripts/verify.sh --full
```

**Acceptance criteria**:
- [ ] All scripts have `--help` flag
- [ ] Consistent flag naming (`--skip-X`, `--dry-run`)
- [ ] All use `common.sh` for shared functions
- [ ] Preflight checks in all scripts (directory, Docker, containers)
- [ ] Real-time logging in demo and 3DSG scripts
- [ ] `--skip_task_planning` default in demo commands

### 7.4 Chat-Derived Requirements Coverage

**Verify each chat-sourced change has a home**:

| Change | README.md | MANUAL_VERIFICATION.md | Script | Status |
|--------|-----------|------------------------|--------|--------|
| `--skip_task_planning` flag | ✓ Common flags table | ✓ All demo commands | ✓ `run_demo.sh` default | [ ] |
| CLIP key remapping (A) | - | ✓ Phase 5 keyboard table | - | [ ] |
| `device` parameter fix | ✓ Troubleshooting | - | - | [ ] |
| Empty objects handling | ✓ Common pitfalls | ✓ Phase 9 edge cases | - | [ ] |
| Real-time logging (`python -u`) | ✓ Development workflow | ✓ All test commands | ✓ `run_demo.sh`, `run_3dsg_only.sh` | [ ] |
| LightGlue device mapping | ✓ Troubleshooting | - | - | [ ] |
| X11 forwarding setup | ✓ Prerequisites | ✓ Phase 1.4 | ✓ `setup` | [ ] |
| NVIDIA graphics capability | ✓ Environment variables | - | - | [ ] |
| 3DSG-only workflow | ✓ Development workflow | ✓ Phase 6 | ✓ `run_3dsg_only.sh` | [ ] |
| Interactive viewer controls | - | ✓ Phase 5.2 | - | [ ] |
| Container restart for file edits | ✓ Development workflow | ✓ Phase 9.3 | - | [ ] |

**Acceptance criteria**:
- [ ] All 11 chat-derived changes documented
- [ ] No orphaned changes (each has ≥1 documentation reference)
- [ ] Critical changes (real-time logging, `--skip_task_planning`) in multiple locations

### 7.5 Backward Compatibility Validation

**Test existing user workflows still work**:
```bash
# Old command (should still work with deprecation warning)
docker exec dovsg-main conda run -n dovsg python demo.py --tags room1
# Expected: Works but shows buffer warning

# New command (recommended)
docker exec dovsg-main bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate dovsg && python -u /app/demo.py --tags room1"
# Expected: Works with real-time output

# Old script (archived)
./scripts/demo  # (if still present before archival)
# Expected: Works but shows deprecation warning

# New script (replacement)
./scripts/run_demo.sh --help
# Expected: Works with new flags
```

**Acceptance criteria**:
- [ ] Old `conda run` pattern still works (graceful degradation)
- [ ] Deprecation warnings clear and actionable
- [ ] Migration path documented in deprecation banners

---

## 8. Timeline & Risk Assessment

### 8.1 Implementation Phases

**Phase 1: Documentation Consolidation** (4-6 hours)
- Rewrite `docker/README.md` (new device setup only)
- Update `docker/MANUAL_VERIFICATION.md` (9 phases, chat-derived changes)
- Create `.env.example` and `compose.override.example.yml`
- Add inline comments to `docker-compose.yml`

**Phase 2: Script Streamlining** (3-4 hours)
- Merge `build`, `download`, `init-dirs` into `setup`
- Rename and update `demo` → `run_demo.sh`
- Update `run_3dsg_only.sh` (real-time logging, `--skip_task_planning`)
- Create `verify.sh` (automated testing)
- Update `start` (X11 connection test)

**Phase 3: Archival** (1-2 hours)
- Create `_archive/` directories
- Move deprecated files with banners
- Create `_archive/README_DEPRECATION.md` index
- Add minimal cross-links in live docs

**Phase 4: Validation** (2-3 hours)
- Test on fresh Ubuntu VM
- Run all 9 MANUAL_VERIFICATION phases
- Test all 5 canonical scripts
- Verify backward compatibility
- Check chat-derived requirements coverage

**Total Estimated Time**: 10-15 hours

### 8.2 Risk Analysis

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Breaking existing user workflows** | High | Medium | Maintain backward compatibility, deprecation warnings, clear migration paths |
| **Missing chat-derived changes** | Medium | Low | Systematic review of worklog.md, cross-reference with code changes |
| **Incomplete GPU variant documentation** | Medium | Medium | Test both NVIDIA and Mesa paths, provide compose overrides |
| **X11 setup varies by distribution** | Medium | High | Document Wayland fallback, provide troubleshooting for common distros |
| **Real-time logging pattern too verbose** | Low | Medium | Document both patterns, explain tradeoffs |
| **Archived files cause confusion** | Medium | Low | Clear deprecation banners, minimal cross-linking, index file |
| **Verification script false positives** | Low | Medium | Manual test procedures still primary, script as helper only |

### 8.3 Rollback Plan

**If critical issues discovered**:

1. **Immediate rollback** (git revert):
```bash
git revert HEAD  # Revert cleanup commit
git push origin master
```

2. **Partial rollback** (restore specific files):
```bash
git checkout HEAD~1 -- docker/README.md  # Restore old README
git checkout HEAD~1 -- docker/scripts/demo  # Restore old demo script
```

3. **Archive the cleanup attempt**:
```bash
mkdir -p .claude/failed_attempts/docker_cleanup_20250126/
git show HEAD:docker/README.md > .claude/failed_attempts/docker_cleanup_20250126/README.md
# Document lessons learned
```

4. **Communication**:
- Update `.claude/worklog.md` with rollback reasoning
- Create GitHub issue documenting specific failure mode
- Propose revised cleanup plan with lessons learned

### 8.4 Success Metrics

**Quantitative**:
- [ ] Documentation files: 4 → 2 (50% reduction)
- [ ] Script files: 9 → 7 (22% reduction, clearer separation)
- [ ] Chat-derived changes documented: 11/11 (100% coverage)
- [ ] New device setup time: <2 hours (excluding downloads)
- [ ] Manual verification phases: 9 complete sets of tests

**Qualitative**:
- [ ] New users can set up without external help
- [ ] All test commands copy-paste without modification
- [ ] GPU and Mesa paths clearly distinguished
- [ ] Real-time logging pattern consistently applied
- [ ] Deprecation strategy preserves historical context

---

## 9. Open Questions & Decisions Needed

### 9.1 Decisions Required Before Implementation

1. **CLIP key binding**:
   - Worklog shows user changed 'Q' → 'A' manually
   - Should we standardize on 'A' or suggest different key?
   - **Recommendation**: Use 'A' (user's choice), document in MANUAL_VERIFICATION Phase 5

2. **Task planning default**:
   - Should `--skip_task_planning` be default (current plan) or opt-in?
   - **Recommendation**: Default to skip (most users don't have OpenAI API key), use `--with-task-planning` to enable

3. **Mesa documentation depth**:
   - How detailed should Mesa fallback instructions be?
   - **Recommendation**: Brief section in README, full details in compose override example

4. **Verification script scope**:
   - Should `verify.sh` run full preprocessing (15-30 min) or just quick checks?
   - **Recommendation**: Two modes (`--quick` = 5 min checks, `--full` = interactive prompts for long tests)

5. **Archive cross-linking**:
   - Link from every relevant section or single index reference?
   - **Recommendation**: Single index reference in appendix, avoid cluttering main content

### 9.2 Future Enhancements (Post-Cleanup)

- **Automated testing**: Expand `verify.sh` to CI/CD pipeline
- **Docker image pre-built**: Publish to Docker Hub to skip 30-60 min build
- **GUI variants**: Document VNC/noVNC for remote access
- **Performance tuning guide**: Resolution, buffer size, stride optimization
- **Multi-scene workflows**: Batch processing, scene comparison

---

## 10. Appendix: File Diff Preview

### 10.1 Before/After Documentation Structure

**Before**:
```
docker/
├── README.md (191 lines, mixed setup + usage)
├── MANUAL_VERIFICATION.md (393 lines, outdated)
├── COMPLETE_X11_GUI_TESTING.md (362 lines, duplicate)
├── 3dsg_only_plan.md (184 lines, duplicate)
└── scripts/ (9 files)
```

**After**:
```
docker/
├── README.md (350 lines, setup ONLY)
├── MANUAL_VERIFICATION.md (600 lines, complete test matrix)
├── .env.example (40 lines, NEW)
├── compose.override.example.yml (80 lines, NEW)
├── _archive/
│   ├── README_DEPRECATION.md (40 lines, index)
│   ├── X11_GUI_TESTING_20250126.md (362 lines, archived)
│   └── 3DSG_ONLY_PLAN_20250126.md (184 lines, archived)
└── scripts/ (7 files total = 5 canonical + 2 utilities)
```

### 10.2 Line Count Comparison

| File | Before | After | Change | Notes |
|------|--------|-------|--------|-------|
| `README.md` | 191 | 350 | +159 | Expanded setup, added troubleshooting |
| `MANUAL_VERIFICATION.md` | 393 | 600 | +207 | Added Phases 6-9, updated all commands |
| `COMPLETE_X11_GUI_TESTING.md` | 362 | - | -362 | Merged into MANUAL_VERIFICATION |
| `3dsg_only_plan.md` | 184 | - | -184 | Merged into MANUAL_VERIFICATION |
| `.env.example` | - | 40 | +40 | NEW |
| `compose.override.example.yml` | - | 80 | +80 | NEW |
| `scripts/setup` | 66 | ~150 | +84 | Merged 3 scripts |
| `scripts/demo` | 186 | - | -186 | Replaced by run_demo.sh |
| `scripts/run_demo.sh` | - | ~120 | +120 | NEW |
| `scripts/verify.sh` | - | ~200 | +200 | NEW |
| **Total** | **1382** | **1540** | **+158** | Net increase due to detail, fewer redundant files |

**Analysis**: Slight line count increase (+11%) but much better organization, reduced redundancy (2 docs instead of 4), clearer script responsibilities.

---

## 11. Implementation Checklist

**Before starting**:
- [ ] Create feature branch: `git checkout -b cleanup/docker-docs-scripts`
- [ ] Update `.claude/worklog.md` with plan approval
- [ ] Backup current state: `git tag backup-pre-cleanup-20250126`

**Phase 1: Documentation**:
- [ ] Rewrite `docker/README.md` (sections 1-9 from plan)
- [ ] Update `docker/MANUAL_VERIFICATION.md` (phases 1-9 from plan)
- [ ] Create `docker/.env.example`
- [ ] Create `docker/compose.override.example.yml`
- [ ] Add inline comments to `docker-compose.yml`
- [ ] Update top-level `README.md` (link to docker/README.md)

**Phase 2: Scripts**:
- [ ] Update `scripts/setup` (merge build/download/init-dirs)
- [ ] Update `scripts/start` (add X11 test)
- [ ] Create `scripts/run_demo.sh` (replace demo)
- [ ] Update `scripts/run_3dsg_only.sh` (add --skip_task_planning)
- [ ] Create `scripts/verify.sh` (automated testing)
- [ ] Update `scripts/common.sh` (add test helper functions)

**Phase 3: Archival**:
- [ ] Create `docker/_archive/` and `docker/scripts/_archive/`
- [ ] Move `COMPLETE_X11_GUI_TESTING.md` to `_archive/X11_GUI_TESTING_20250126.md`
- [ ] Move `3dsg_only_plan.md` to `_archive/3DSG_ONLY_PLAN_20250126.md`
- [ ] Move `scripts/demo` to `scripts/_archive/demo_interactive_20250126`
- [ ] Add deprecation banners to all archived files
- [ ] Create `_archive/README_DEPRECATION.md` index

**Phase 4: Validation**:
- [ ] Test on fresh Ubuntu 22.04 VM (from scratch setup)
- [ ] Run all MANUAL_VERIFICATION phases 1-9
- [ ] Test all 5 canonical scripts with `--help` and `--dry-run`
- [ ] Verify backward compatibility (old commands still work)
- [ ] Check all 11 chat-derived changes documented

**Phase 5: Finalization**:
- [ ] Update `.claude/worklog.md` with cleanup summary
- [ ] Run `git status` to verify all changes tracked
- [ ] Commit with detailed message:
  ```
  Docker docs & scripts cleanup

  - Consolidated 4 docs → 2 (README.md setup-only, MANUAL_VERIFICATION.md testing)
  - Streamlined 9 scripts → 7 (5 canonical + 2 utilities)
  - Documented 11 chat-derived changes (--skip_task_planning, CLIP key, device fixes, etc.)
  - Added .env.example and compose.override.example.yml for GPU variants
  - Archived deprecated docs to _archive/ with migration paths

  See .claude/tasks/docker_docs_cleanup_plan.md for full details.
  ```
- [ ] Push to remote: `git push origin cleanup/docker-docs-scripts`
- [ ] Create pull request with plan as description
- [ ] Tag successful implementation: `git tag docker-cleanup-v1-20250126`

---

**End of Plan**

**Next Steps**: Upon approval, proceed with Phase 1 (Documentation Consolidation)
