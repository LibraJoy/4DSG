#!/bin/bash

# DovSG Docker Setup - Streamlined Version
# Run this script to set up the complete DovSG environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(dirname "$DOCKER_DIR")"

echo "🚀 DovSG Docker Setup"
echo "===================="
echo "Project directory: $PROJECT_DIR"
echo "Docker directory: $DOCKER_DIR"
echo ""

# Check if running from correct location
if [[ ! -f "$DOCKER_DIR/docker-compose.yml" ]]; then
    echo "❌ Error: Please run this script from the docker/ directory"
    echo "Usage: cd docker && ./scripts/setup.sh"
    exit 1
fi

# Check Docker installation
echo "🔍 Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check NVIDIA Docker runtime
if ! docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi &> /dev/null; then
    echo "⚠️  Warning: NVIDIA Docker runtime not working. GPU features may not work."
    echo "Please install nvidia-container-toolkit if you need GPU support."
fi

echo "✅ Prerequisites check completed"
echo ""

# Menu for setup options
echo "🛠️  Setup Options:"
echo "1) Complete setup (recommended for new installations)"
echo "2) Build containers only"
echo "3) Download checkpoints only"
echo "4) Start containers"
echo "5) Run demo"
echo ""
read -p "Choose an option (1-5): " choice

case $choice in
    1)
        echo "🚀 Running complete setup..."
        echo ""
        
        # Run all setup steps
        echo "📁 Creating directories..."
        "$SCRIPT_DIR/02_create_directories.sh"
        
        echo "📦 Downloading checkpoints (this may take a while)..."
        "$SCRIPT_DIR/03_download_checkpoints.sh"
        
        echo "🏗️  Building containers (this will take 30-60 minutes)..."
        "$SCRIPT_DIR/04_build_containers.sh"
        
        echo "🚀 Starting containers..."
        "$SCRIPT_DIR/05_start_containers.sh"
        
        echo ""
        echo "✅ Complete setup finished!"
        echo "You can now run the demo with: ./scripts/06_run_demo.sh"
        ;;
    2)
        echo "🏗️  Building containers..."
        "$SCRIPT_DIR/04_build_containers.sh"
        ;;
    3)
        echo "📦 Downloading checkpoints..."
        "$SCRIPT_DIR/03_download_checkpoints.sh"
        ;;
    4)
        echo "🚀 Starting containers..."
        "$SCRIPT_DIR/05_start_containers.sh"
        ;;
    5)
        echo "🎯 Running demo..."
        "$SCRIPT_DIR/06_run_demo.sh"
        ;;
    *)
        echo "❌ Invalid option. Please choose 1-5."
        exit 1
        ;;
esac

echo ""
echo "📋 Next Steps:"
echo "• To run DovSG demo: ./scripts/06_run_demo.sh"
echo "• To access DovSG container: docker compose exec dovsg conda run -n dovsg bash"
echo "• To access DROID-SLAM container: docker compose exec droid-slam conda run -n droidenv bash"
echo "• To stop containers: docker compose down"
echo ""
echo "🎉 Setup complete! Happy coding!"