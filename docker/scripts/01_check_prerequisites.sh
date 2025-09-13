#!/bin/bash

# 01_check_prerequisites.sh
# Check system prerequisites for DovSG Docker setup

set -e

echo "📋 Checking Prerequisites"
echo "========================="

# Check Docker
check_docker() {
    echo -n "Checking Docker... "
    if command -v docker &> /dev/null; then
        echo "✅ Found"
        docker --version
    else
        echo "❌ Docker not found!"
        echo "Please install Docker first: https://docs.docker.com/get-docker/"
        return 1
    fi
}

# Check Docker Compose V2
check_docker_compose() {
    echo -n "Checking Docker Compose V2... "
    if docker compose version &> /dev/null; then
        echo "✅ Found"
        docker compose version
    else
        echo "❌ Docker Compose V2 not available!"
        echo "Please install Docker Compose V2: https://docs.docker.com/compose/install/"
        return 1
    fi
}

# Check NVIDIA Docker (optional but recommended)
check_nvidia_docker() {
    echo -n "Checking NVIDIA Docker runtime... "
    if docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu20.04 nvidia-smi &> /dev/null; then
        echo "✅ Working"
        echo "GPU detected:"
        docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu20.04 nvidia-smi --query-gpu=name --format=csv,noheader | head -1
    else
        echo "⚠️  Not working properly"
        echo ""
        echo "This might be because:"
        echo "1. NVIDIA Docker runtime not installed"
        echo "2. No NVIDIA GPU available"
        echo "3. GPU drivers not properly installed"
        echo ""
        echo "Install NVIDIA Docker runtime:"
        echo "https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html"
        echo ""
        read -p "Continue anyway? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
}

# Check disk space (need ~50GB)
check_disk_space() {
    echo -n "Checking available disk space... "
    AVAILABLE_GB=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
    echo "${AVAILABLE_GB}GB available"
    
    if [ "$AVAILABLE_GB" -lt 50 ]; then
        echo "⚠️  Warning: Less than 50GB available"
        echo "Docker build + checkpoints + data will need ~50GB"
        read -p "Continue anyway? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    else
        echo "✅ Sufficient space"
    fi
}

# Check if we're in the right directory
check_directory() {
    echo -n "Checking current directory... "
    if [ -f "docker-compose.yml" ] && [ -d "dockerfiles" ] && [ -d "scripts" ]; then
        echo "✅ In docker/ directory"
    else
        echo "❌ Wrong directory!"
        echo "Please run from the docker/ directory:"
        echo "cd docker/ && ./scripts/01_check_prerequisites.sh"
        return 1
    fi
}

# Main execution
main() {
    check_directory
    echo ""
    
    check_docker
    echo ""
    
    check_docker_compose  
    echo ""
    
    check_nvidia_docker
    echo ""
    
    check_disk_space
    echo ""
    
    echo "🎉 Prerequisites check completed!"
    echo ""
    echo "Next step: ./scripts/02_create_directories.sh"
}

main "$@"