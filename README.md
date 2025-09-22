# 4DSG: DovSG + Docker Unified Environment

A comprehensive Docker-based environment for **DovSG (Dense Open-Vocabulary 3D Scene Graphs)** that works across different Ubuntu versions and hardware configurations.

## Repository Structure

```
4DSG/
├── README.md                    # This file - main project documentation
├── .gitignore                   # Ignores large files (checkpoints, data, etc.)
├── docker/                     # Docker environment setup
│   ├── docker-compose.yml
│   ├── dockerfiles/
│   ├── scripts/
│   └── README.md               # Docker-specific documentation  
├── DovSG/                      # Original DovSG project (modified .gitignore)
│   ├── dovsg/                  # Core DovSG code
│   ├── demo.py
│   ├── setup.py
│   ├── checkpoints/           # IGNORED - Download separately (see below)
│   ├── data_example/          # IGNORED - Download separately (see below) 
│   ├── third_party/           # IGNORED - Downloaded during Docker build
│   └── ...
└── shared_data/               # Runtime data sharing between containers
```

## Quick Start

### Prerequisites (One-time setup per machine)

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

# 3. Add user to docker group 
sudo usermod -aG docker $USER
# IMPORTANT: Log out and log back in for group changes to take effect

# 4. Verify installation (after logging back in)
docker --version
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu20.04 nvidia-smi
```

** CRITICAL**: You MUST log out and log back in after step 3, or the Docker setup will fail with permission errors.

### Setup & Installation

```bash
# 1. Clone this repository
git clone <your-repo-url> 4DSG
cd 4DSG

# 2. Download large files (required - not in Git due to size limits)
./scripts/download_large_files.sh

# 3. Run Docker setup
cd docker/
./scripts/setup.sh                    # Interactive setup
# OR step-by-step:
./scripts/01_check_prerequisites.sh   # Verify system
./scripts/02_create_directories.sh    # Create structure  
./scripts/03_download_checkpoints.sh  # Download models (~8GB)
./scripts/04_build_containers.sh      # Build containers (30-60 min)
./scripts/05_start_containers.sh      # Start services

# 4. Test the installation
./scripts/06_run_demo.sh              # Run demo
```

## Large Files (Not in Git Repository)

Due to Git size limitations, these large directories must be downloaded separately:

### Required Downloads:

1. **Model Checkpoints (~11GB)**:
   ```bash
   cd docker/
   ./scripts/03_download_checkpoints.sh
   ```

2. **Sample Data (~23GB)**: 
   Download from [Google Drive](https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing)
   ```bash
   # Extract to: DovSG/data_example/room1/
   ```

3. **Third-party Dependencies (~206MB)**:
   ```bash
   # Downloaded automatically during Docker build
   # Includes: segment-anything-2, GroundingDINO, etc.
   ```

### Download Script (Optional - Create this):
```bash
# Create scripts/download_large_files.sh
cd docker/
./scripts/03_download_checkpoints.sh
echo "Checkpoints downloaded"
echo "   manually download sample data from Google Drive"
echo "   URL: https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x"
echo "   Extract to: ../DovSG/data_example/room1/"
```

## Usage

### Common Commands (run from docker/ folder):

```bash
# Start services
docker compose up -d

# Run DovSG demo
docker compose exec dovsg conda run -n dovsg python demo.py --help
docker compose exec dovsg conda run -n dovsg python demo.py \
    --tags "room1" \
    --preprocess \
    --debug \
    --task_description "Test run"

# Shell access for development
docker compose exec dovsg bash

# View logs
docker compose logs -f

# Stop services
docker compose down
```

### Development Workflow:

```bash
# 1. Make changes to DovSG code (git tracked)
vim DovSG/dovsg/your_changes.py

# 2. Test in Docker environment
docker compose exec dovsg conda run -n dovsg python demo.py

# 3. Commit your changes
git add DovSG/
git commit -m "Your improvements to DovSG"
git push
```

## Docker Services

### Main Services:
- **dovsg**: Main DovSG environment (CUDA 12.1, PyTorch 2.3)
- **droid-slam**: DROID-SLAM environment (CUDA 11.8, PyTorch 1.10)

### Built-in Components:
- SegmentAnything2 (SAM2)
- GroundingDINO  
- PyTorch3D
- LightGlue
- ACE (Pose Estimation)
- DROID-SLAM
- All dependencies pre-compiled and tested


## Migration from Original DovSG

If you have an existing DovSG setup:

```bash
# 1. Backup your existing work
cp -r /path/to/original/DovSG /backup/

# 2. Clone this repository 
git clone <your-repo-url> 4DSG-new

# 3. Copy your data/checkpoints (if you have them)
cp -r /backup/DovSG/checkpoints/ 4DSG-new/DovSG/
cp -r /backup/DovSG/data_example/ 4DSG-new/DovSG/

# 4. Run the new Docker setup
cd 4DSG-new/docker/
./scripts/setup.sh
```

## Troubleshooting

### Docker Permission Issues:
```bash
# Check docker group membership
groups | grep docker

# Add to docker group and restart session
sudo usermod -aG docker $USER
# Log out and back in
```

### GPU Not Detected:
```bash
# Test GPU access
docker compose exec dovsg nvidia-smi

# If fails, reinstall NVIDIA Container Toolkit (see Prerequisites)
```

### Build Failures:
```bash
# Clean rebuild
docker compose down
docker system prune -a
docker compose build --no-cache
```


## License

This project combines:
- **DovSG**: Original license from [BJHYZJ/DovSG](https://github.com/BJHYZJ/DovSG)
- **Docker Setup**: MIT License (this repository)

## References

- **Original DovSG**: [https://github.com/BJHYZJ/DovSG](https://github.com/BJHYZJ/DovSG)
- **DovSG Paper**: [Dense Open-Vocabulary 3D Scene Graphs](https://arxiv.org/abs/your-paper-link)
- **Docker Documentation**: [docker/README.md](docker/README.md)

---