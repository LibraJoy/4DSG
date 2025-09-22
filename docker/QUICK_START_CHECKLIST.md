# 🚀 Quick Start Checklist: Build and Run DovSG Demo

## ✅ Pre-Flight Check (Run these first)

```bash
# 1. Test Docker works
docker run hello-world

# 2. Test GPU access
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu20.04 nvidia-smi

# 3. Navigate to correct directory
cd /home/cerlab/4DSG/docker/
pwd  # Should show: /home/cerlab/4DSG/docker
```

**❌ If any fail, stop here and fix first** (see main guide for solutions)

## 🔽 Step 1: Download Data

```bash
# Download checkpoints (~8GB, required)
./scripts/03_download_checkpoints.sh
```

**✅ Verify:** `ls ../DovSG/checkpoints/` should show .pth files

## 🏗️ Step 2: Build Images (The Fixed Versions)

```bash
# Build both containers (30-60 minutes total)
docker compose build
```

**✅ Success indicators:**
- No "setup.py install is deprecated" errors
- No CUDA version mismatch errors
- Both builds complete successfully

**❌ If build fails:** See debugging section in STEP_BY_STEP_GUIDE.md

## 🚀 Step 3: Start Containers

```bash
# Start the containers
docker compose up -d

# Check they're running
docker compose ps
```

**✅ Expected output:** Both containers show "running" status

## 🧪 Step 4: Test Demo

```bash
# Test DovSG loads
docker compose exec dovsg conda run -n dovsg python demo.py --help
```

**✅ Success:** Shows help text without import errors

**✅ Optional (if you have sample data):**
```bash
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_description "Test run"
```

## 🐛 If Something Goes Wrong

### Quick Debug Commands:
```bash
# Test environment quickly
./scripts/quick_debug.sh

# Interactive shell for debugging
./scripts/debug_dovsg.sh shell
```

### Inside the debug shell, test step by step:
```bash
# Test CUDA
conda run -n dovsg python -c "import torch; print(torch.cuda.is_available())"

# Test packages
conda run -n dovsg python -c "import numpy; print('NumPy version:', numpy.__version__)"

# Test demo
conda run -n dovsg python demo.py --help
```

## 🔄 Clean Start (If Everything Fails)

```bash
# Stop everything
docker compose down

# Clean Docker completely
docker system prune -af

# Rebuild from scratch
docker compose build --no-cache

# Try again
docker compose up -d
docker compose exec dovsg conda run -n dovsg python demo.py --help
```

## 🎯 Final Goal Check

**You know it's working when:**
1. ✅ `docker compose ps` shows both containers running
2. ✅ `docker compose exec dovsg conda run -n dovsg python demo.py --help` shows help text
3. ✅ No import errors or CUDA errors
4. ✅ (Optional) Demo runs with sample data

**That's it! The DovSG demo should now work in your Docker environment.**