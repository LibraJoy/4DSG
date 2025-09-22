#!/bin/bash

# Quick debug script for testing package installations and fixes
# Usage: ./scripts/quick_debug.sh

set -e

echo "🚀 DovSG Quick Debug & Test"
echo "==========================="

# Start development containers if not running
start_dev_containers() {
    echo "🔧 Starting development containers..."
    docker compose -f docker-compose.dev.yml up -d
    echo "⏳ Waiting for containers to be ready..."
    sleep 5
}

# Quick CUDA and environment check
quick_check() {
    echo "🔍 Quick environment check..."

    echo "--- DovSG Environment ---"
    docker compose -f docker-compose.dev.yml exec dovsg-dev conda run -n dovsg python -c "
import torch
print(f'PyTorch: {torch.__version__} (CUDA: {torch.version.cuda if torch.cuda.is_available() else \"Not available\"})')
print(f'GPU Available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'GPU Count: {torch.cuda.device_count()}')
    for i in range(torch.cuda.device_count()):
        print(f'  GPU {i}: {torch.cuda.get_device_name(i)}')
"

    echo "--- DROID-SLAM Environment ---"
    docker compose -f docker-compose.dev.yml exec droid-slam-dev conda run -n droidenv python -c "
import torch
print(f'PyTorch: {torch.__version__} (CUDA: {torch.version.cuda if torch.cuda.is_available() else \"Not available\"})')
print(f'GPU Available: {torch.cuda.is_available()}')
"
}

# Test critical package imports
test_imports() {
    echo "📦 Testing critical package imports..."

    echo "--- DovSG Package Tests ---"
    docker compose -f docker-compose.dev.yml exec dovsg-dev conda run -n dovsg python -c "
import sys
test_packages = [
    'torch', 'torchvision', 'numpy', 'opencv-cv2', 'matplotlib',
    'supervision', 'transformers', 'open3d', 'scipy'
]

for pkg in test_packages:
    try:
        if pkg == 'opencv-cv2':
            import cv2
            print(f'✅ {pkg}: {cv2.__version__}')
        else:
            module = __import__(pkg)
            version = getattr(module, '__version__', 'unknown')
            print(f'✅ {pkg}: {version}')
    except ImportError as e:
        print(f'❌ {pkg}: {e}')
"

    echo "--- DROID-SLAM Package Tests ---"
    docker compose -f docker-compose.dev.yml exec droid-slam-dev conda run -n droidenv python -c "
test_packages = ['torch', 'numpy', 'opencv-cv2', 'open3d']

for pkg in test_packages:
    try:
        if pkg == 'opencv-cv2':
            import cv2
            print(f'✅ {pkg}: {cv2.__version__}')
        else:
            module = __import__(pkg)
            version = getattr(module, '__version__', 'unknown')
            print(f'✅ {pkg}: {version}')
    except ImportError as e:
        print(f'❌ {pkg}: {e}')
"
}

# Test DovSG demo
test_dovsg_demo() {
    echo "🧪 Testing DovSG demo..."
    docker compose -f docker-compose.dev.yml exec dovsg-dev conda run -n dovsg python demo.py --help 2>&1 | head -20
}

# Test DROID-SLAM
test_droid_slam() {
    echo "🧪 Testing DROID-SLAM..."
    docker compose -f docker-compose.dev.yml exec droid-slam-dev bash -c "
cd /app/DROID-SLAM
conda run -n droidenv python -c 'import sys; sys.path.append(\"/app/DROID-SLAM\"); import droid_slam; print(\"✅ DROID-SLAM imported successfully\")'
" 2>&1 || echo "❌ DROID-SLAM test failed"
}

# Interactive package installer
interactive_install() {
    echo "📦 Interactive Package Installer"
    echo "Enter package names to test install (one per line, empty line to finish):"

    while read -r package; do
        [ -z "$package" ] && break
        echo "Installing $package in DovSG environment..."
        docker compose -f docker-compose.dev.yml exec dovsg-dev conda run -n dovsg pip install "$package"
    done
}

# Main execution
case "${1:-all}" in
    "start")
        start_dev_containers
        ;;
    "check")
        quick_check
        ;;
    "imports")
        test_imports
        ;;
    "dovsg")
        test_dovsg_demo
        ;;
    "droid")
        test_droid_slam
        ;;
    "install")
        interactive_install
        ;;
    "all"|"")
        start_dev_containers
        quick_check
        test_imports
        test_dovsg_demo
        test_droid_slam
        ;;
    "help")
        echo "Quick Debug Script Usage:"
        echo "  $0 [command]"
        echo ""
        echo "Commands:"
        echo "  start     - Start development containers"
        echo "  check     - Quick CUDA/environment check"
        echo "  imports   - Test critical package imports"
        echo "  dovsg     - Test DovSG demo"
        echo "  droid     - Test DROID-SLAM"
        echo "  install   - Interactive package installer"
        echo "  all       - Run all tests (default)"
        echo "  help      - Show this help"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

echo ""
echo "🎯 Quick Debug Complete!"
echo "For interactive debugging:"
echo "  - DovSG: ./scripts/debug_dovsg.sh"
echo "  - DROID-SLAM: ./scripts/debug_droid.sh"