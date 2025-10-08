# DovSG Docker Environment Setup

Quick start guide for setting up the DovSG Docker environment on a new machine.

## Prerequisites

### 1. System Requirements
- Ubuntu 20.04+ (tested on 20.04, 22.04, 24.04)
- NVIDIA GPU with ≥8GB VRAM
- 50GB free disk space (containers + checkpoints + data)
- 16GB+ RAM recommended

### 2. Required Software

Install in this order:

#### Docker Engine & Compose
```bash
# Install Docker (official instructions)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker  # Or logout/login

# Verify
docker --version  # Should show v24.0+
docker compose version  # Should show v2.20+
```

#### NVIDIA Container Toolkit
```bash
# Add NVIDIA package repositories
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Verify GPU access
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

#### X11 Forwarding (for GUI visualization)
```bash
# For X11 systems (traditional Linux)
xhost +local:docker

# For Wayland systems (Ubuntu 22.04+, newer desktops)
# If above fails, also try:
export WAYLAND_DISPLAY=""  # Force XWayland
xhost +SI:localuser:root

# Add to ~/.bashrc for persistence:
echo "xhost +local:docker > /dev/null 2>&1" >> ~/.bashrc
```

`./scripts/docker_run.sh` automatically runs `xhost +local:docker` before starting the containers, so you typically only need the manual command when managing services directly with `docker compose`.

## Quick Start

### 1. Clone Repository
```bash
git clone --recursive https://github.com/BJHYZJ/4DSG.git
cd 4DSG/docker
```

### 2. Download Dependencies

Third-party code (required):
```bash
./scripts/download_third_party.sh
```

Model checkpoints (~11GB, required):
```bash
./scripts/download
```

Example data (~23GB, optional - see instructions in download script output)

### 3. Build Docker Images
```bash
./scripts/docker_build.sh
# First build: 15-30 minutes
# Subsequent builds: 2-5 minutes (cached)
```

### 4. Start Containers
```bash
./scripts/docker_run.sh
# Starts both dovsg and droid-slam containers
```

### 5. Verify Setup
See [MANUAL_VERIFICATION.md](MANUAL_VERIFICATION.md) for complete testing instructions.

Quick test:
```bash
docker compose exec dovsg python -c "import torch; print(f'PyTorch: {torch.__version__}, CUDA: {torch.cuda.is_available()}')"
```

Expected output:
```
PyTorch: 2.3.1+cu121, CUDA: True
```

## Troubleshooting

### "Cannot connect to Docker daemon"
**Cause**: Docker service not running or user lacks permissions
**Fix**:
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

### "could not select device driver with capabilities: [[gpu]]"
**Cause**: NVIDIA Container Toolkit not installed
**Fix**: Follow "NVIDIA Container Toolkit" section above

### "cannot open display: :0"
**Cause**: X11 forwarding not configured
**Fix**:
```bash
xhost +local:docker
# Verify DISPLAY is set in container:
docker compose exec dovsg bash -c 'echo $DISPLAY'
```

### Build fails with "No space left on device"
**Cause**: Insufficient disk space for Docker layers
**Fix**:
```bash
# Clean up unused Docker resources
./scripts/docker_clean.sh
# Or manually:
docker system prune -a
```

## Next Steps

- **Testing & Demos**: See [MANUAL_VERIFICATION.md](MANUAL_VERIFICATION.md)
- **Development**: Use `./scripts/docker_run.sh --shell` for interactive shell
- **Original DovSG docs**: See [../DovSG/README.md](../DovSG/README.md)

## Support

- DovSG project: https://github.com/BJHYZJ/DovSG
- Docker environment issues: Open issue in 4DSG repository
