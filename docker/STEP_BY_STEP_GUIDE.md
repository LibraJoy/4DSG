# Complete Step-by-Step Guide: Build Docker Images and Run DovSG Demo

## 🎯 Goal
Build Docker images with fixed dependencies and successfully run the DovSG demo.

## 📋 Prerequisites Check

**Before starting, run these commands to verify your system:**

```bash
# 1. Check Docker is installed and working
docker --version
docker run hello-world

# 2. Check Docker Compose is working
docker compose version

# 3. Check if you can access Docker without sudo
docker ps

# 4. Test NVIDIA Docker (GPU support)
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu20.04 nvidia-smi
```

**If any of these fail, fix them first:**
- Docker permission issues: `sudo usermod -aG docker $USER` (then log out/in)
- NVIDIA Docker issues: Install NVIDIA Container Toolkit (see main README.md)

## 🚀 Step 1: Navigate to Docker Directory

```bash
cd /home/cerlab/4DSG/docker/
pwd  # Should show: /home/cerlab/4DSG/docker
ls   # Should see: docker-compose.yml, dockerfiles/, scripts/
```

## 🔧 Step 2: Download Required Data

**Download model checkpoints (required, ~8GB):**
```bash
./scripts/03_download_checkpoints.sh
```

**Manual download (sample data for demo):**
1. Go to: https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing
2. Download the data
3. Extract to: `../DovSG/data_example/room1/`

**Verify data is in place:**
```bash
ls ../DovSG/checkpoints/     # Should see various .pth files
ls ../DovSG/data_example/    # Should see room1/ folder (if downloaded)
```

## 🏗️ Step 3: Build Docker Images (Fixed Version)

**Build both containers with the fixes I implemented:**

```bash
# Build DROID-SLAM container (this should work now with pip install fix)
docker compose build droid-slam

# Build DovSG container (this should work now with CUDA 12.1 fix)
docker compose build dovsg
```

**Expected behavior:**
- DROID-SLAM build should complete without the setup.py error
- DovSG build should download packages correctly with CUDA 12.1
- Total build time: 30-60 minutes depending on your internet/system

**If build fails, see "Debugging Build Issues" section below.**

## 🚀 Step 4: Start Containers

```bash
# Start both containers
docker compose up -d

# Check they're running
docker compose ps
```

**Expected output:**
```
NAME               COMMAND               SERVICE       STATUS
dovsg-droid-slam   conda run -n ...      droid-slam    running
dovsg-main         conda run -n ...      dovsg         running
```

## 🧪 Step 5: Test DovSG Demo

**First, test that DovSG loads without errors:**
```bash
docker compose exec dovsg conda run -n dovsg python demo.py --help
```

**Expected output:** Help text showing demo.py options without errors.

**Run the actual demo (if you have sample data):**
```bash
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_description "Test run"
```

## 🐛 Debugging Build Issues

### If DROID-SLAM Build Fails:

**Check the error message carefully. Common issues:**

1. **"setup.py install is deprecated" error:**
   ```bash
   # This should be fixed in my updated Dockerfile, but if it persists:
   # Check if the fix is in place:
   grep -n "pip install -e" dockerfiles/Dockerfile.droid-slam
   # Should show line 77: RUN conda run -n droidenv pip install -e .
   ```

2. **CUDA compilation errors:**
   ```bash
   # Check the Dockerfile has correct compiler settings:
   grep -A5 "CC=/usr/bin/gcc" dockerfiles/Dockerfile.droid-slam
   ```

### If DovSG Build Fails:

1. **CUDA version mismatch errors:**
   ```bash
   # Verify the fix is in place:
   grep "cuda:12.1" dockerfiles/Dockerfile.dovsg
   grep "cu121" dockerfiles/Dockerfile.dovsg
   ```

2. **Package version conflicts:**
   ```bash
   # Check numpy version is correct:
   grep "numpy==1.23.0" dockerfiles/Dockerfile.dovsg

   # Check supervision version:
   grep "supervision" dockerfiles/Dockerfile.dovsg
   ```

3. **Network/download issues:**
   ```bash
   # Clean up and retry with no cache:
   docker system prune -af
   docker compose build --no-cache
   ```

## 🔧 Interactive Debugging Workflow

**If the demo doesn't work, use the development environment for faster debugging:**

### 1. Build Development Environment:
```bash
docker compose -f docker-compose.dev.yml build
docker compose -f docker-compose.dev.yml up -d
```

### 2. Interactive Testing:
```bash
# Quick validation
./scripts/quick_debug.sh

# Interactive DovSG shell
./scripts/debug_dovsg.sh shell

# Inside the container, you can test step by step:
conda run -n dovsg python -c "import torch; print(torch.cuda.is_available())"
conda run -n dovsg python -c "import numpy; print(numpy.__version__)"
conda run -n dovsg python demo.py --help
```

### 3. Fix Issues Interactively:
```bash
# If a package is missing or wrong version:
conda run -n dovsg pip install package_name==correct_version

# Test immediately without rebuilding:
conda run -n dovsg python demo.py --help
```

## 📊 Complete Testing Workflow

### Test 1: Environment Validation
```bash
# Test GPU access
docker compose exec dovsg conda run -n dovsg python -c "
import torch
print(f'CUDA available: {torch.cuda.is_available()}')
print(f'GPU count: {torch.cuda.device_count()}')
"
```

### Test 2: Key Package Imports
```bash
# Test critical DovSG imports
docker compose exec dovsg conda run -n dovsg python -c "
try:
    import torch, numpy, cv2, open3d
    print('✅ Basic packages imported successfully')

    import supervision
    print(f'✅ Supervision version: {supervision.__version__}')

    # Test if demo.py can be imported
    import sys
    sys.path.append('/app')
    from dovsg.controller import Controller
    print('✅ DovSG Controller imported successfully')
except Exception as e:
    print(f'❌ Import error: {e}')
"
```

### Test 3: DROID-SLAM
```bash
docker compose exec droid-slam conda run -n droidenv python -c "
import sys
sys.path.append('/app/DROID-SLAM')
try:
    import droid_slam
    print('✅ DROID-SLAM imported successfully')
except Exception as e:
    print(f'❌ DROID-SLAM error: {e}')
"
```

### Test 4: Full Demo (with sample data)
```bash
# Only if you have downloaded sample data to ../DovSG/data_example/room1/
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_description "Test demo run"
```

## 🚨 Common Issues and Solutions

### Issue 1: "Permission denied" when running docker commands
**Solution:**
```bash
sudo usermod -aG docker $USER
# Log out and log back in, then test:
docker run hello-world
```

### Issue 2: "NVIDIA-SMI has failed"
**Solution:**
```bash
# Check NVIDIA drivers
nvidia-smi

# If that works, reinstall NVIDIA Container Toolkit:
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Issue 3: Build takes too long or fails with network errors
**Solution:**
```bash
# Clean everything and rebuild with better caching:
docker system prune -af
docker compose build --parallel
```

### Issue 4: Demo fails with import errors
**Solution:**
```bash
# Use development environment for faster debugging:
./scripts/debug_dovsg.sh shell
# Inside container, test imports one by one and fix as needed
```

## ✅ Success Indicators

**Build Success:**
- Both containers build without errors
- No "deprecated setup.py" messages
- No CUDA version mismatch errors

**Runtime Success:**
- `docker compose ps` shows both containers running
- `docker compose exec dovsg conda run -n dovsg python demo.py --help` shows help text
- No import errors when testing key packages

**Demo Success:**
- DovSG demo runs without crashing
- GPU is detected and utilized
- Sample data (if available) processes correctly

## 🎯 Quick Commands Summary

```bash
# Complete workflow in order:
cd /home/cerlab/4DSG/docker/
./scripts/03_download_checkpoints.sh
docker compose build
docker compose up -d
docker compose exec dovsg conda run -n dovsg python demo.py --help

# If issues, use debug environment:
./scripts/quick_debug.sh
./scripts/debug_dovsg.sh shell
```

Follow this guide step by step, and you should be able to successfully build and run the DovSG demo!