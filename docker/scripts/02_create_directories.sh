#!/bin/bash

# 02_create_directories.sh
# Create necessary directory structure for DovSG Docker setup

set -e

echo "📁 Creating Directory Structure"
echo "==============================="

# Check if DovSG project exists
check_dovsg_project() {
    if [ -d "../DovSG" ]; then
        echo "✅ DovSG project found at ../DovSG"
        return 0
    else
        echo "❌ DovSG project not found!"
        echo ""
        echo "Please clone the DovSG project first:"
        echo "cd .. && git clone --recursive https://github.com/BJHYZJ/DovSG.git"
        echo ""
        read -p "Continue creating directories anyway? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Create data directories
create_data_directories() {
    echo ""
    echo "Creating data directories..."
    
    mkdir -p ../DovSG/data_example
    echo "✅ Created ../DovSG/data_example"
    
    mkdir -p ../DovSG/checkpoints
    echo "✅ Created ../DovSG/checkpoints"
    
    mkdir -p ../shared_data
    echo "✅ Created ../shared_data"
}

# Create checkpoint subdirectories with proper structure
create_checkpoint_structure() {
    echo ""
    echo "Creating checkpoint directory structure..."
    
    CHECKPOINTS_DIR="../DovSG/checkpoints"
    
    # Create subdirectories for different models
    mkdir -p "$CHECKPOINTS_DIR"/{droid-slam,GroundingDINO,segment-anything-2,recognize_anything,bert-base-uncased,CLIP-ViT-H-14-laion2B-s32B-b79K,anygrasp}
    
    echo "✅ Created checkpoint subdirectories:"
    ls -la "$CHECKPOINTS_DIR"
}

# Show expected directory structure
show_directory_structure() {
    echo ""
    echo "📁 Expected Directory Structure:"
    echo "================================"
    echo "your-workspace/"
    echo "├── DovSG/                    # Original DovSG project"
    echo "│   ├── data_example/         # ✅ Created"
    echo "│   │   └── room1/           # (Download sample data here)"
    echo "│   ├── checkpoints/         # ✅ Created"
    echo "│   │   ├── droid-slam/      # ✅ Created"
    echo "│   │   ├── GroundingDINO/   # ✅ Created"
    echo "│   │   └── ...              # ✅ Other model dirs created"
    echo "│   └── dovsg/"
    echo "├── docker/                  # This Docker setup"
    echo "│   ├── docker-compose.yml"
    echo "│   └── scripts/"
    echo "└── shared_data/             # ✅ Created"
}

# Check permissions
check_permissions() {
    echo ""
    echo "Checking directory permissions..."
    
    if [ -w "../DovSG" ] && [ -w "../shared_data" ]; then
        echo "✅ Write permissions OK"
    else
        echo "⚠️  Permission issues detected"
        echo "You might need to fix permissions:"
        echo "sudo chown -R \$USER:$USER ../DovSG ../shared_data"
    fi
}

# Main execution
main() {
    check_dovsg_project
    create_data_directories
    create_checkpoint_structure
    check_permissions
    show_directory_structure
    
    echo ""
    echo "🎉 Directory setup completed!"
    echo ""
    echo "Next step: ./scripts/03_download_checkpoints.sh (optional)"
    echo "       or: ./scripts/04_build_containers.sh"
}

main "$@"