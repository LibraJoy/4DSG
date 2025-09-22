#!/bin/bash

# DovSG Development Environment Setup
# This script sets up both production and development Docker environments

set -e

echo "🚀 DovSG Development Environment Setup"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available. Please install Docker Compose V2."
        exit 1
    fi

    # Check NVIDIA Docker
    if ! docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu20.04 nvidia-smi &> /dev/null; then
        print_warning "NVIDIA Docker runtime not working. GPU acceleration may not be available."
        print_warning "Please install NVIDIA Container Toolkit if you need GPU support."
    else
        print_success "NVIDIA Docker runtime is working"
    fi

    # Check if user is in docker group
    if ! groups | grep -q docker; then
        print_error "User is not in docker group. Please run:"
        echo "  sudo usermod -aG docker \$USER"
        echo "  Then log out and log back in."
        exit 1
    fi

    print_success "Prerequisites check passed"
}

# Setup directory structure
setup_directories() {
    print_status "Setting up directory structure..."

    cd "$(dirname "$0")/.."  # Go to docker/ directory

    # Create shared data directory
    mkdir -p ../shared_data

    # Ensure third_party directory exists
    mkdir -p ../DovSG/third_party

    print_success "Directory structure created"
}

# Interactive setup menu
interactive_setup() {
    echo ""
    echo "🎯 Setup Options:"
    echo "1. Quick Development Setup (recommended for debugging)"
    echo "2. Full Production Build"
    echo "3. Development Only (skip production build)"
    echo "4. Fix & Test Existing Setup"
    echo "5. Custom Setup"
    echo ""

    read -p "Choose an option [1-5]: " choice

    case $choice in
        1)
            development_setup
            ;;
        2)
            full_production_setup
            ;;
        3)
            development_only_setup
            ;;
        4)
            fix_and_test_setup
            ;;
        5)
            custom_setup
            ;;
        *)
            print_error "Invalid option"
            exit 1
            ;;
    esac
}

# Quick development setup
development_setup() {
    print_status "Starting Quick Development Setup..."

    # Download checkpoints if needed
    if [ ! -d "../DovSG/checkpoints" ] || [ -z "$(ls -A ../DovSG/checkpoints)" ]; then
        print_status "Downloading checkpoints..."
        ./03_download_checkpoints.sh
    else
        print_success "Checkpoints already exist"
    fi

    # Build development containers
    print_status "Building development containers..."
    docker compose -f docker-compose.dev.yml build

    # Start development environment
    print_status "Starting development environment..."
    docker compose -f docker-compose.dev.yml up -d

    # Quick validation
    print_status "Running quick validation..."
    ./quick_debug.sh check

    print_success "Development environment ready!"
    echo ""
    echo "🔧 Development Commands:"
    echo "  ./scripts/debug_dovsg.sh    - DovSG interactive debugging"
    echo "  ./scripts/debug_droid.sh    - DROID-SLAM interactive debugging"
    echo "  ./scripts/quick_debug.sh    - Quick validation and testing"
    echo ""
    echo "🐚 Quick Access:"
    echo "  docker compose -f docker-compose.dev.yml exec dovsg-dev bash"
    echo "  docker compose -f docker-compose.dev.yml exec droid-slam-dev bash"
}

# Full production setup
full_production_setup() {
    print_status "Starting Full Production Setup..."

    # Run all setup scripts
    ./01_check_prerequisites.sh
    ./02_create_directories.sh
    ./03_download_checkpoints.sh
    ./04_build_containers.sh
    ./05_start_containers.sh

    # Also build development environment
    print_status "Building development environment..."
    docker compose -f docker-compose.dev.yml build
    docker compose -f docker-compose.dev.yml up -d

    # Test both environments
    print_status "Testing production environment..."
    ./06_run_demo.sh

    print_status "Testing development environment..."
    ./quick_debug.sh

    print_success "Full setup complete!"
}

# Development only setup
development_only_setup() {
    print_status "Setting up development environment only..."

    # Just build and start dev containers
    docker compose -f docker-compose.dev.yml build
    docker compose -f docker-compose.dev.yml up -d

    # Quick test
    ./quick_debug.sh check

    print_success "Development environment ready!"
}

# Fix and test existing setup
fix_and_test_setup() {
    print_status "Fixing and testing existing setup..."

    # Stop everything
    docker compose down || true
    docker compose -f docker-compose.dev.yml down || true

    # Clean up
    print_status "Cleaning up containers..."
    docker system prune -f

    # Rebuild with fixed Dockerfiles
    print_status "Rebuilding with fixes..."
    docker compose build --no-cache
    docker compose -f docker-compose.dev.yml build --no-cache

    # Start development environment
    docker compose -f docker-compose.dev.yml up -d

    # Comprehensive test
    print_status "Running comprehensive tests..."
    ./quick_debug.sh all

    print_success "Fix and test complete!"
}

# Custom setup
custom_setup() {
    echo ""
    echo "🛠️ Custom Setup Options:"
    echo "1. Build specific container (dovsg/droid-slam)"
    echo "2. Reset and rebuild everything"
    echo "3. Update development environment only"
    echo "4. Test specific component"
    echo ""

    read -p "Choose custom option [1-4]: " custom_choice

    case $custom_choice in
        1)
            read -p "Enter container name (dovsg/droid-slam): " container
            docker compose build "$container"
            docker compose -f docker-compose.dev.yml build "${container}-dev"
            ;;
        2)
            docker compose down
            docker compose -f docker-compose.dev.yml down
            docker system prune -af
            docker compose build --no-cache
            docker compose -f docker-compose.dev.yml build --no-cache
            ;;
        3)
            docker compose -f docker-compose.dev.yml build --no-cache
            docker compose -f docker-compose.dev.yml up -d
            ;;
        4)
            read -p "Test component (dovsg/droid/imports/all): " component
            ./quick_debug.sh "$component"
            ;;
    esac
}

# Show final instructions
show_final_instructions() {
    echo ""
    echo "🎉 Setup Complete!"
    echo "================="
    echo ""
    echo "🔧 Development Workflow:"
    echo "  1. Edit code in ../DovSG/ (changes are live-mounted)"
    echo "  2. Test with: ./scripts/debug_dovsg.sh"
    echo "  3. Validate with: ./scripts/quick_debug.sh"
    echo ""
    echo "📁 Key Files:"
    echo "  - docker-compose.yml: Production environment"
    echo "  - docker-compose.dev.yml: Development environment"
    echo "  - scripts/debug_*.sh: Interactive debugging"
    echo "  - .claude/tasks/docker_environment_fix.md: Implementation plan"
    echo ""
    echo "🚨 Remember:"
    echo "  - Download sample data manually from Google Drive"
    echo "  - Use development environment for debugging (faster)"
    echo "  - Production environment for final testing"
    echo ""
    echo "📖 Next Steps:"
    echo "  ./scripts/quick_debug.sh    # Quick validation"
    echo "  ./scripts/debug_dovsg.sh    # Interactive DovSG shell"
    echo "  ./06_run_demo.sh           # Production demo"
}

# Main execution
main() {
    check_prerequisites
    setup_directories
    interactive_setup
    show_final_instructions
}

# Run main function
main "$@"