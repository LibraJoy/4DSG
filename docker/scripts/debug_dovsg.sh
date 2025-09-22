#!/bin/bash

# Debug script for DovSG interactive development
# Usage: ./scripts/debug_dovsg.sh [command]

set -e

echo "🔧 DovSG Debug Shell"
echo "===================="

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
    echo "🔍 Validating DovSG environment..."
    docker compose -f docker-compose.dev.yml exec dovsg-dev conda run -n dovsg python -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'CUDA version: {torch.version.cuda}')
    print(f'GPU count: {torch.cuda.device_count()}')
"
}

# Interactive shell access
interactive_shell() {
    echo "🐚 Starting interactive shell in DovSG container..."
    echo "   - Conda environment 'dovsg' available"
    echo "   - Use 'conda run -n dovsg python' for single commands"
    echo "   - Code changes are live-mounted from ../DovSG/"
    echo ""
    docker compose -f docker-compose.dev.yml exec dovsg-dev bash
}

# Quick package installation for testing
install_package() {
    local package=$1
    if [ -z "$package" ]; then
        echo "Usage: $0 install <package_name>"
        exit 1
    fi
    echo "📦 Installing $package in DovSG environment..."
    docker compose -f docker-compose.dev.yml exec dovsg-dev conda run -n dovsg pip install "$package"
}

# Test DovSG demo
test_demo() {
    echo "🧪 Testing DovSG demo..."
    docker compose -f docker-compose.dev.yml exec dovsg-dev conda run -n dovsg python demo.py --help
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
        test_demo
        ;;
    "help")
        echo "DovSG Debug Script Usage:"
        echo "  $0 [command]"
        echo ""
        echo "Commands:"
        echo "  check     - Check if containers are running"
        echo "  validate  - Validate environment and CUDA setup"
        echo "  shell     - Enter interactive shell (default)"
        echo "  install   - Install a package for testing"
        echo "  test      - Test DovSG demo command"
        echo "  help      - Show this help"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac