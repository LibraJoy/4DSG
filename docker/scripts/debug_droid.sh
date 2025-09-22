#!/bin/bash

# Debug script for DROID-SLAM interactive development
# Usage: ./scripts/debug_droid.sh [command]

set -e

echo "🔧 DROID-SLAM Debug Shell"
echo "========================="

# Check if development containers are running
check_containers() {
    if ! docker compose -f docker-compose.dev.yml ps | grep -q "Up"; then
        echo "❌ Development containers not running!"
        echo "Start them with: docker compose -f docker-compose.dev.yml up -d"
        exit 1
    fi
    echo "✅ Development containers are running"
}

# Quick environment validation
validate_environment() {
    echo "🔍 Validating DROID-SLAM environment..."
    docker compose -f docker-compose.dev.yml exec droid-slam-dev conda run -n droidenv python -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'CUDA version: {torch.version.cuda}')
    print(f'GPU count: {torch.cuda.device_count()}')
try:
    import droid_slam
    print('✅ DROID-SLAM imported successfully')
except ImportError as e:
    print(f'❌ DROID-SLAM import failed: {e}')
"
}

# Interactive shell access
interactive_shell() {
    echo "🐚 Starting interactive shell in DROID-SLAM container..."
    echo "   - Conda environment 'droidenv' available"
    echo "   - Use 'conda run -n droidenv python' for single commands"
    echo "   - DROID-SLAM code is at /app/DROID-SLAM/"
    echo ""
    docker compose -f docker-compose.dev.yml exec droid-slam-dev bash
}

# Quick package installation for testing
install_package() {
    local package=$1
    if [ -z "$package" ]; then
        echo "Usage: $0 install <package_name>"
        exit 1
    fi
    echo "📦 Installing $package in DROID-SLAM environment..."
    docker compose -f docker-compose.dev.yml exec droid-slam-dev conda run -n droidenv pip install "$package"
}

# Test DROID-SLAM installation
test_droid() {
    echo "🧪 Testing DROID-SLAM installation..."
    docker compose -f docker-compose.dev.yml exec droid-slam-dev conda run -n droidenv python -c "
import sys
sys.path.append('/app/DROID-SLAM')
try:
    import droid_slam
    print('✅ DROID-SLAM module loaded successfully')
    print(f'DROID-SLAM location: {droid_slam.__file__}')
except ImportError as e:
    print(f'❌ DROID-SLAM import failed: {e}')
    print('Available packages:')
    import pkg_resources
    for pkg in pkg_resources.working_set:
        if 'droid' in pkg.project_name.lower():
            print(f'  - {pkg.project_name}: {pkg.version}')
"
}

# Reinstall DROID-SLAM for debugging
reinstall_droid() {
    echo "🔄 Reinstalling DROID-SLAM..."
    docker compose -f docker-compose.dev.yml exec droid-slam-dev bash -c "
cd /app/DROID-SLAM
conda run -n droidenv pip uninstall -y droid-slam || true
conda run -n droidenv pip install -e .
"
}

# Main command handling
case "${1:-shell}" in
    "check")
        check_containers
        ;;
    "validate")
        check_containers
        validate_environment
        ;;
    "shell"|"")
        check_containers
        interactive_shell
        ;;
    "install")
        check_containers
        install_package "$2"
        ;;
    "test")
        check_containers
        test_droid
        ;;
    "reinstall")
        check_containers
        reinstall_droid
        ;;
    "help")
        echo "DROID-SLAM Debug Script Usage:"
        echo "  $0 [command]"
        echo ""
        echo "Commands:"
        echo "  check     - Check if containers are running"
        echo "  validate  - Validate environment and CUDA setup"
        echo "  shell     - Enter interactive shell (default)"
        echo "  install   - Install a package for testing"
        echo "  test      - Test DROID-SLAM installation"
        echo "  reinstall - Reinstall DROID-SLAM for debugging"
        echo "  help      - Show this help"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac