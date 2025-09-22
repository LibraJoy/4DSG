# DovSG Docker Setup

A standalone Docker environment for DovSG that works across different Ubuntu versions (20.04, 22.04) and ROS configurations.


## Directory Structure

```
your-workspace/
├── DovSG/                    # Original DovSG project (clone from GitHub)
│   ├── dovsg/
│   ├── third_party/
│   └── demo.py
├── docker/                   # This Docker setup (your Git repo)
│   ├── docker compose.yml
│   ├── dockerfiles/
│   ├── scripts/
│   └── README.md (this file)
└── shared_data/             # Created by setup
```

## Setup for New Device

### Prerequisites (Install on Host System):
```bash
# 1. Install Docker + Docker Compose V2
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Install NVIDIA Container Toolkit (for GPU support)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# 3. Add user to docker group and refresh session
sudo usermod -aG docker $USER
# IMPORTANT: Log out and log back in (or restart) for group changes to take effect

# 4. Verify installations (after logging back in)
docker --version
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu20.04 nvidia-smi
```

**IMPORTANT**: After running the prerequisites, you MUST log out and log back in (or restart your session) before proceeding with the setup steps. The docker group membership will not take effect until you do this.

### Setup Steps:

#### 1. Clone projects:
```bash
# Clone DovSG project with submodules
git clone --recursive https://github.com/BJHYZJ/DovSG.git

# If you already cloned without --recursive, initialize submodules:
# cd DovSG && git submodule update --init --recursive

# Clone or copy this Docker setup (put in your own repo)
# Structure should be:
# your-workspace/
# ├── DovSG/           # Original project
# └── docker/          # This Docker setup
```

#### 2. Run modular setup:
```bash
cd docker/

# Option A: Step-by-step (recommended for debugging)
./scripts/01_check_prerequisites.sh    # Check system requirements
./scripts/02_create_directories.sh     # Create directory structure  
./scripts/03_download_checkpoints.sh   # Download models (~8GB)
./scripts/04_build_containers.sh       # Build containers (30-60 min)
./scripts/05_start_containers.sh       # Start containers
./scripts/06_run_demo.sh              # Test with demos

# Option B: Guided setup
./scripts/setup.sh                     # Choose complete or individual
```

#### 3. Manual downloads (required):
```bash
# Download sample data from Google Drive:
# https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing
# Extract to: ../DovSG/data_example/room1/
```

#### 4. Test the setup:
```bash
./scripts/06_run_demo.sh              # Interactive demo runner
# OR
docker compose exec dovsg conda run -n dovsg python demo.py --help
```

## Usage

### Common Commands (run from docker/ folder):
```bash
# Build containers
docker compose build

# Start services
docker compose up -d

# Stop services  
docker compose down

# View logs
docker compose logs -f

# Shell access
# FOR INTERACTIVE SESSIONS - Use basic bash (then manually activate if needed):
docker compose exec dovsg bash
docker compose exec droid-slam bash

# Inside the shell, you can then run commands with conda:
# conda run -n dovsg python your_script.py
# conda run -n droidenv python your_script.py

# FOR SINGLE COMMANDS - Use conda run directly:
docker compose exec dovsg conda run -n dovsg python demo.py --help
docker compose exec droid-slam conda run -n droidenv python /app/DROID-SLAM/demo.py --help

# Note: Interactive conda environments (conda activate) are not configured in current builds

# Run DovSG demo
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_description "Test run"

# Run DROID-SLAM pose estimation
docker compose exec droid-slam conda run -n droidenv python /app/DROID-SLAM/demo.py \
    --imagedir="/app/data_example/room1" \
    --calib="/app/data_example/room1/calib.txt" \
    --weights="/app/checkpoints/droid-slam/droid.pth"
```

## What's Included

### Docker Services:
- **dovsg**: Main DovSG environment (CUDA 12.1, PyTorch 2.3)
- **droid-slam**: DROID-SLAM environment (CUDA 11.8, PyTorch 1.10)


### For your different machines:

1. **Copy this docker/ folder** to each machine
2. **Clone DovSG project** on each machine  
3. **Run setup** on each machine

```bash
# On each new machine:
git clone --recursive https://github.com/BJHYZJ/DovSG.git
# Copy your docker/ folder
cd docker/
./scripts/setup.sh
docker compose up -d
```

### Version Control Strategy:
```bash
# Keep Docker setup in your own Git repo
cd docker/
git init
git add .
git commit -m "DovSG Docker setup"
git remote add origin your-repo-url
git push origin main

# On other machines:
git clone your-repo-url docker/
git clone --recursive https://github.com/BJHYZJ/DovSG.git
cd docker/ && ./scripts/setup.sh
```

## Data Management

### Checkpoints (~10GB):
- Download automatically via `./scripts/download_checkpoints.sh`
- Shared across containers via volumes
- Stored in `../DovSG/checkpoints/`

### Sample Data:
- Download from [Google Drive](https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing)
- Extract to `../DovSG/data_example/room1/`

## Customization

### Environment Variables:
```bash
# Create .env file in docker/ folder
CUDA_VERSION=12.1
DATA_PATH=/custom/data/path
```

## Troubleshooting

### Build Issues:
```bash
# Clean rebuild
docker compose down
docker system prune -a
docker compose build --no-cache
```

### Docker Permission Issues:
```bash
# If you get "permission denied" errors with docker:
# 1. Check if you're in docker group
groups | grep docker

# 2. If not in group, add yourself and restart session
sudo usermod -aG docker $USER
# Then log out and back in

# 3. Temporary fix (until logout/login)
sudo chmod 666 /var/run/docker.sock

# 4. Test docker access
docker run --rm hello-world
```

### GPU Issues:
```bash
# Test GPU access
docker compose exec dovsg nvidia-smi

# Install NVIDIA Container Toolkit if needed
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
# Note: Also ensure user is in docker group and logged out/in:
# sudo usermod -aG docker $USER && echo "Log out and back in for group changes"
```

### Path Issues:
```bash
# Make sure you're running from docker/ folder
pwd  # Should end with /docker
ls   # Should see docker compose.yml
```