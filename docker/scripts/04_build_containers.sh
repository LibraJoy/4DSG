#!/bin/bash

# 04_build_containers.sh
# Build Docker containers (can build individually or together)

set -e

echo "🔨 Docker Container Builder"
echo "==========================="

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Must be run from the docker/ directory"
    exit 1
fi

# Show available options
show_build_options() {
    echo "Build options:"
    echo "1. Build both containers (recommended)"
    echo "2. Build DROID-SLAM container only"
    echo "3. Build DovSG container only"
    echo "4. Rebuild from scratch (no cache)"
    echo "5. Exit"
    echo ""
}

# Build both containers
build_both() {
    echo "🔨 Building both containers..."
    echo "This will take 30-60 minutes depending on your internet and CPU."
    echo ""
    
    read -p "Continue with build? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "⏳ Building containers... (this will take a while)"
        docker compose build
        echo ""
        echo "✅ Both containers built successfully!"
    else
        echo "⏭️  Build cancelled"
    fi
}

# Build DROID-SLAM only
build_droid_slam() {
    echo "🔨 Building DROID-SLAM container..."
    echo "This will take 15-20 minutes."
    echo ""
    
    read -p "Continue? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "⏳ Building DROID-SLAM container..."
        docker compose build droid-slam
        echo ""
        echo "✅ DROID-SLAM container built successfully!"
    else
        echo "⏭️  Build cancelled"
    fi
}

# Build DovSG only
build_dovsg() {
    echo "🔨 Building DovSG container..."
    echo "This will take 30-45 minutes (more dependencies)."
    echo ""
    
    read -p "Continue? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "⏳ Building DovSG container..."
        docker compose build dovsg
        echo ""
        echo "✅ DovSG container built successfully!"
    else
        echo "⏭️  Build cancelled"
    fi
}

# Rebuild from scratch
rebuild_from_scratch() {
    echo "🔨 Rebuilding from scratch (no cache)..."
    echo "This will take longer but ensures clean build."
    echo ""
    
    read -p "Continue? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "⏳ Rebuilding without cache..."
        docker compose build --no-cache
        echo ""
        echo "✅ Containers rebuilt successfully!"
    else
        echo "⏭️  Build cancelled"
    fi
}

# Show container status
show_container_status() {
    echo ""
    echo "📊 Current container status:"
    echo "==========================="
    
    # Check if images exist
    if docker images | grep -q "dovsg-main"; then
        echo "✅ DovSG container image exists"
    else
        echo "❌ DovSG container image not found"
    fi
    
    if docker images | grep -q "dovsg-droid-slam"; then
        echo "✅ DROID-SLAM container image exists"
    else
        echo "❌ DROID-SLAM container image not found"
    fi
    
    echo ""
    echo "Container sizes:"
    docker images | grep dovsg || echo "No dovsg images found"
}

# Main menu
main() {
    show_container_status
    
    while true; do
        echo ""
        show_build_options
        read -p "Choose an option (1-5): " choice
        
        case $choice in
            1)
                build_both
                break
                ;;
            2)
                build_droid_slam
                break
                ;;
            3)
                build_dovsg
                break
                ;;
            4)
                rebuild_from_scratch
                break
                ;;
            5)
                echo "👋 Exiting"
                exit 0
                ;;
            *)
                echo "❌ Invalid option. Please choose 1-5."
                ;;
        esac
    done
    
    echo ""
    echo "Next step: ./scripts/05_start_containers.sh"
}

main "$@"