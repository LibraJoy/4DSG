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

## What is DovSG?

DovSG constructs dynamic 3D scene graphs for robot navigation and manipulation. The pipeline:
1. **Data Collection** → RGB-D images + camera poses (via DROID-SLAM)
2. **3DSG Construction** → Object detection, segmentation, spatial relationships
3. **Interactive Visualization** → Open3D viewer with scene graph overlay

## Quick Start

```bash
git clone https://github.com/BJHYZJ/4DSG.git
cd 4DSG/docker

# One-command setup (see docker/README.md for prerequisites)
./scripts/download_third_party.sh && ./scripts/download && \
./scripts/docker_build.sh && ./scripts/docker_run.sh
```

**Complete Guides**:
- **Setup & Prerequisites** → [docker/README.md](docker/README.md)
- **Testing & Demos** → [docker/MANUAL_VERIFICATION.md](docker/MANUAL_VERIFICATION.md)

## Development Workflow

**Management Scripts** (`docker/scripts/`):
- `docker_build.sh` - Build containers
- `docker_run.sh` - Start containers (`--shell` for interactive)
- `docker_clean.sh` - Cleanup containers/volumes
- `download_third_party.sh`, `download` - Data downloads

**Live Code Editing**:
- Edit `DovSG/` files on host → changes reflect immediately in containers
- Interactive shell: `./scripts/docker_run.sh --shell`
- See [docker/MANUAL_VERIFICATION.md](docker/MANUAL_VERIFICATION.md) for demo commands

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
git clone https://github.com/BJHYZJ/4DSG.git
cd 4DSG

# Copy existing data if available
cp -r /backup/DovSG/checkpoints/ DovSG/ 2>/dev/null || true
cp -r /backup/DovSG/data_example/ DovSG/ 2>/dev/null || true

# Setup new environment
cd docker/
./scripts/docker_build.sh && ./scripts/docker_run.sh
```

## Troubleshooting

See [docker/README.md](docker/README.md#troubleshooting) for setup issues and [docker/MANUAL_VERIFICATION.md](docker/MANUAL_VERIFICATION.md#troubleshooting-tests) for runtime issues.

## License

This project combines:
- **DovSG**: Original license from [BJHYZJ/DovSG](https://github.com/BJHYZJ/DovSG)
- **Docker Setup**: MIT License (this repository)

## References

- **Original DovSG**: [https://github.com/BJHYZJ/DovSG](https://github.com/BJHYZJ/DovSG)
- **Docker Documentation**: [docker/README.md](docker/README.md)