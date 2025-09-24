#!/bin/bash

# common.sh - Shared functions for DovSG Docker scripts

# Color and emoji constants for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the correct directory
check_directory() {
    if [ ! -f "docker-compose.yml" ]; then
        echo -e " ${RED}Error: Must be run from the docker/ directory${NC}"
        echo "Usage: cd docker && ./scripts/$(basename $0)"
        exit 1
    fi
}

# Check if Docker is installed and working
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e " ${RED}Docker is not installed. Please install Docker first.${NC}"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e " ${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
        exit 1
    fi
}

# Check if NVIDIA Docker runtime is working
check_nvidia_docker() {
    if ! docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi &> /dev/null; then
        echo -e "  ${YELLOW}Warning: NVIDIA Docker runtime not working. GPU features may not work.${NC}"
        echo "Please install nvidia-container-toolkit if you need GPU support."
        return 1
    fi
    return 0
}

# Check if containers are built
check_containers_built() {
    if ! docker images | grep -q "docker-droid-slam\|docker-dovsg"; then
        echo -e " ${RED}Containers not built yet!${NC}"
        echo "Please run: ./scripts/build first"
        exit 1
    fi
    echo -e " ${GREEN}Container images found${NC}"
}

# Show container status
show_container_status() {
    echo ""
    echo " Container Status:"
    echo "==================="

    if docker compose ps | grep -q "Up"; then
        echo -e " ${GREEN}Containers are running:${NC}"
        docker compose ps
    else
        echo -e " ${YELLOW}Containers are not running${NC}"
        docker compose ps
    fi
}

# Test if containers are responding
test_containers() {
    echo ""
    echo " Testing containers..."

    echo ""
    echo "Testing DovSG container:"
    if docker compose exec -T dovsg conda run -n dovsg python --version; then
        echo -e " ${GREEN}DovSG container working${NC}"
    else
        echo -e " ${RED}DovSG container not responding${NC}"
        return 1
    fi

    echo ""
    echo "Testing DROID-SLAM container:"
    if docker compose exec -T droid-slam conda run -n droidenv python --version; then
        echo -e " ${GREEN}DROID-SLAM container working${NC}"
    else
        echo -e " ${RED}DROID-SLAM container not responding${NC}"
        return 1
    fi

    echo ""
    echo "Testing GPU access:"
    if docker compose exec -T dovsg nvidia-smi | head -1; then
        echo -e " ${GREEN}GPU access working${NC}"
    else
        echo -e " ${RED}GPU access not working${NC}"
        return 1
    fi

    return 0
}

# Start containers with status feedback
start_containers() {
    echo ""
    echo " Starting containers..."

    docker compose up -d

    if [ $? -eq 0 ]; then
        echo -e " ${GREEN}Containers started successfully!${NC}"
        sleep 3
        show_container_status
    else
        echo -e " ${RED}Failed to start containers${NC}"
        exit 1
    fi
}

# Stop containers
stop_containers() {
    echo ""
    echo " Stopping containers..."

    docker compose down

    if [ $? -eq 0 ]; then
        echo -e " ${GREEN}Containers stopped successfully!${NC}"
    else
        echo -e " ${RED}Failed to stop containers${NC}"
        exit 1
    fi
}

# Restart containers
restart_containers() {
    echo ""
    echo " Restarting containers..."

    docker compose restart

    if [ $? -eq 0 ]; then
        echo -e " ${GREEN}Containers restarted successfully!${NC}"
        sleep 3
        show_container_status
    else
        echo -e " ${RED}Failed to restart containers${NC}"
        exit 1
    fi
}

# Print usage information
print_usage() {
    local script_name=$(basename $0)
    echo "Usage: ./scripts/$script_name [options]"
    echo ""
}

# Print next steps information
print_next_steps() {
    echo ""
    echo " Next Steps:"
    echo "• To run DovSG demo: ./scripts/demo"
    echo "• To access DovSG container: docker compose exec dovsg conda run -n dovsg bash"
    echo "• To access DROID-SLAM container: docker compose exec droid-slam conda run -n droidenv bash"
    echo "• To stop containers: ./scripts/start --stop"
    echo ""
}