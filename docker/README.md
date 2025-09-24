# DovSG Docker Development Environment

A streamlined Docker environment for DovSG development that works across different Ubuntu versions and provides interactive debugging capabilities.

## Directory Structure

```
your-workspace/
├── DovSG/                    # Original DovSG project (clone from GitHub)
│   ├── dovsg/
│   ├── third_party/
│   └── demo.py
├── docker/                   # This Docker setup
│   ├── docker-compose.yml
│   ├── dockerfiles/
│   ├── scripts/
│   └── README.md
└── shared_data/             # Runtime data sharing
```

## Quick Start

### Prerequisites
Install Docker, Docker Compose, and NVIDIA Container Toolkit on your host system:

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install NVIDIA Container Toolkit for GPU support
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Add user to docker group
sudo usermod -aG docker $USER
```

**Important**: Log out and log back in after adding yourself to the docker group.

### Setup

1. Clone the DovSG project:
```bash
git clone --recursive https://github.com/BJHYZJ/DovSG.git
```

2. Run the setup script:
```bash
cd docker/
./scripts/setup
```

3. Download sample data manually from [Google Drive](https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing) and extract to `../DovSG/data_example/room1/`

### Test Installation
```bash
./scripts/demo
```

## Development Workflow

### Script Commands
All scripts are located in `scripts/` and should be run from the `docker/` directory:

```bash
# Environment management
./scripts/setup          # Complete environment setup
./scripts/build          # Build containers
./scripts/start          # Start containers
./scripts/start --stop   # Stop containers
./scripts/start --test   # Test container functionality

# Development
./scripts/demo           # Interactive demo runner with multiple options
./scripts/download       # Download model checkpoints
```

### Script Options
```bash
# Build options
./scripts/build --droid-slam    # Build only DROID-SLAM container
./scripts/build --dovsg         # Build only DovSG container
./scripts/build --no-cache      # Clean rebuild without cache

# Container management
./scripts/start                 # Start containers (default)
./scripts/start --stop          # Stop containers
./scripts/start --restart       # Restart containers
./scripts/start --status        # Show container status
./scripts/start --test          # Test container functionality
```

### Interactive Development
The environment supports live code editing and interactive debugging:

```bash
# Access container shells for interactive development
docker compose exec dovsg bash
docker compose exec droid-slam bash

# Run commands in containers
docker compose exec dovsg conda run -n dovsg python demo.py --help
docker compose exec droid-slam conda run -n droidenv python /app/DROID-SLAM/demo.py --help

# Example: Run DovSG demo
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_description "Move the red pepper to the plate"
```

## Architecture

### Docker Services
- **dovsg**: Main DovSG environment (CUDA 12.1, PyTorch 2.3, Python 3.9)
- **droid-slam**: DROID-SLAM environment (CUDA 11.8, PyTorch 1.10, Python 3.9)

Both services include interactive development features (tty, stdin_open) and live code mounting for efficient development.

### Data Management

**Model Checkpoints** (approximately 11GB):
- Downloaded automatically via `./scripts/download`
- Stored in `../DovSG/checkpoints/`
- Shared across containers via volume mounts

**Sample Data**:
- Manual download required from [Google Drive](https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing)
- Extract to `../DovSG/data_example/room1/`

## Deployment

### Multi-Machine Setup
1. Clone DovSG project: `git clone --recursive https://github.com/BJHYZJ/DovSG.git`
2. Copy this docker/ folder to each machine
3. Run setup: `cd docker/ && ./scripts/setup`

### Version Control
Track the Docker setup in your own repository:
```bash
cd docker/
git init
git add .
git commit -m "DovSG Docker development environment"
```

## Troubleshooting

### Common Issues

**Permission Denied Errors**:
```bash
# Check docker group membership
groups | grep docker

# Add user to docker group if needed
sudo usermod -aG docker $USER
# Log out and log back in for changes to take effect
```

**GPU Not Working**:
```bash
# Test GPU access
./scripts/start --test

# If GPU test fails, reinstall NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

**Build Failures**:
```bash
# Clean rebuild (only affects this project)
./scripts/start --stop
docker compose build --no-cache
```

**Script Not Found**:
```bash
# Ensure you're in the docker/ directory
pwd  # Should end with /docker
ls   # Should show docker-compose.yml and scripts/
```