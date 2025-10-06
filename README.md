# 4DSG: DovSG Docker Development Environment

A streamlined Docker-based environment for **DovSG (Dense Open-Vocabulary 3D Scene Graphs)** development that provides interactive debugging capabilities and works across different Ubuntu versions.

## Repository Structure

```
4DSG/
├── README.md                    # This documentation
├── docker/                     # Docker development environment
│   ├── docker-compose.yml      # Single compose file for development
│   ├── dockerfiles/            # Container definitions
│   ├── scripts/                # Streamlined management scripts
│   └── README.md               # Docker-specific documentation
├── DovSG/                      # Original DovSG project
│   ├── dovsg/                  # Core DovSG code
│   ├── demo.py                 # Main demo entry point
│   ├── checkpoints/            # Model checkpoints (downloaded separately)
│   ├── data_example/           # Sample data (downloaded separately)
│   └── third_party/            # Dependencies
└── shared_data/               # Runtime data sharing
```

## Quick Start

### Prerequisites
Install Docker, Docker Compose, and NVIDIA Container Toolkit:

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

### Installation

```bash
# Clone this repository
git clone https://github.com/BJHYZJ/4DSG.git
cd 4DSG/docker

# Download dependencies
./scripts/download_third_party.sh  # Third-party code
./scripts/download                  # Model checkpoints

# Build and start
./scripts/docker_build.sh
./scripts/docker_run.sh
```

For complete setup instructions, see **[docker/README.md](docker/README.md)**.

For testing and demos, see **[docker/MANUAL_VERIFICATION.md](docker/MANUAL_VERIFICATION.md)**.

## Development Workflow

### Script Commands
All development operations use streamlined scripts in `docker/scripts/`:

```bash
# Environment management
./scripts/docker_build.sh    # Build containers
./scripts/docker_run.sh       # Start containers
./scripts/docker_run.sh --shell  # Interactive shell
./scripts/docker_clean.sh     # Cleanup containers/volumes

# Data downloads
./scripts/download_third_party.sh  # Clone third-party code
./scripts/download                 # Download checkpoints
```

### Interactive Development
The environment supports live code editing and debugging:

```bash
# Access container shells for development
docker compose exec dovsg bash
docker compose exec droid-slam bash

# Run specific demos
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_description "Move the red pepper to the plate"
```

### Code Changes
```bash
# 1. Edit DovSG code directly (changes reflect immediately)
vim DovSG/dovsg/your_module.py

# 2. Test changes in containers
./scripts/demo

# 3. Commit changes
git add DovSG/
git commit -m "Update DovSG implementation"
```

## Data Requirements

**Model Checkpoints** (approximately 11GB):
- Downloaded automatically via `./scripts/download`
- Stored in `DovSG/checkpoints/`

**Sample Data**:
- Manual download required from [Google Drive](https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing)
- Extract to `DovSG/data_example/room1/`

## Architecture

### Docker Services
- **dovsg**: Main DovSG environment (CUDA 12.1, PyTorch 2.3, Python 3.9)
- **droid-slam**: DROID-SLAM environment (CUDA 11.8, PyTorch 1.10, Python 3.9)

Both services include interactive development features and live code mounting for efficient development.

### Built-in Components
- SegmentAnything2 (SAM2) for object segmentation
- GroundingDINO for object detection
- PyTorch3D for 3D operations
- LightGlue for feature matching
- ACE for pose estimation
- DROID-SLAM for visual odometry
- All dependencies pre-compiled and verified

## Migration from Original DovSG

If you have an existing DovSG installation:

```bash
# Backup existing work
cp -r /path/to/original/DovSG /backup/

# Clone this repository
git clone <your-repo-url> 4DSG-new

# Copy existing data if available
cp -r /backup/DovSG/checkpoints/ 4DSG-new/DovSG/ 2>/dev/null || true
cp -r /backup/DovSG/data_example/ 4DSG-new/DovSG/ 2>/dev/null || true

# Setup new environment
cd 4DSG-new/docker/
./scripts/setup
```

## Troubleshooting

### Common Issues

**Permission Denied Errors**:
```bash
# Check docker group membership
groups | grep docker

# Add user to docker group if needed
sudo usermod -aG docker $USER
# Log out and log back in
```

**GPU Not Working**:
```bash
# Test GPU access
./scripts/start --test

# If GPU test fails, reinstall NVIDIA Container Toolkit (see Prerequisites)
```

**Build Failures**:
```bash
# Clean rebuild (only affects this project)
./scripts/start --stop
docker compose build --no-cache
```

## License

This project combines:
- **DovSG**: Original license from [BJHYZJ/DovSG](https://github.com/BJHYZJ/DovSG)
- **Docker Setup**: MIT License (this repository)

## References

- **Original DovSG**: [https://github.com/BJHYZJ/DovSG](https://github.com/BJHYZJ/DovSG)
- **Docker Documentation**: [docker/README.md](docker/README.md)