#!/bin/bash

# 3DSG-Only Execution Script
# Runs DovSG pipeline skipping heavy preprocessing when artifacts exist

set -e

TAGS="${1:-room1}"
DOCKER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$DOCKER_DIR/../DovSG/data_example/$TAGS"

echo "=== DovSG 3DSG-Only Pipeline ==="
echo "Tags: $TAGS"
echo "Data directory: $DATA_DIR"

# Check for required artifacts
check_artifacts() {
    local missing=0

    echo "Checking required artifacts..."

    if [ ! -d "$DATA_DIR/poses_droidslam" ]; then
        echo "❌ Missing: poses_droidslam/ (run with --preprocess first)"
        missing=1
    else
        echo "✓ Found: poses_droidslam/"
    fi

    if [ ! -d "$DATA_DIR/memory" ]; then
        echo "❌ Missing: memory/ (run with --preprocess first)"
        missing=1
    else
        echo "✓ Found: memory/"
    fi

    if [ $missing -eq 1 ]; then
        echo ""
        echo "Missing required artifacts. Run full preprocessing first:"
        echo "  docker exec dovsg-main conda run -n dovsg python demo.py --tags $TAGS --preprocess"
        exit 1
    fi

    echo "✓ All required artifacts present"
}

# Check container status
check_container() {
    if ! docker exec dovsg-main echo "Container check" > /dev/null 2>&1; then
        echo "❌ Container dovsg-main not running. Start with:"
        echo "  cd $DOCKER_DIR && docker-compose up -d"
        exit 1
    fi
    echo "✓ Container running"
}

# Run 3DSG pipeline
run_3dsg_pipeline() {
    echo ""
    echo "=== Running 3DSG Construction Pipeline ==="

    # Create minimal Python script for 3DSG-only execution
    cat > /tmp/3dsg_only.py << 'EOF'
from dovsg.controller import Controller
import sys

def main():
    tags = sys.argv[1] if len(sys.argv) > 1 else "room1"

    controller = Controller(
        step=0,
        tags=tags,
        interval=3,
        resolution=0.01,
        occ_avoid_radius=0.2,
        save_memory=True,
        debug=True
    )

    print("Loading view dataset...")
    controller.get_view_dataset()

    print("Processing semantic memory...")
    controller.get_semantic_memory()

    print("Processing instances...")
    controller.get_instances()

    print("Constructing 3D scene graph...")
    controller.get_instance_scene_graph()

    print("Extracting LightGlue features...")
    controller.get_lightglue_features()

    print("Opening interactive 3DSG viewer...")
    print("Controls: B=background, C=class colors, R=RGB, F=CLIP, G=scene graph, I=instances, O=bboxes, V=save view")

    controller.show_instances(
        controller.instance_objects,
        clip_vis=True,
        scene_graph=controller.instance_scene_graph,
        show_background=True
    )

if __name__ == "__main__":
    main()
EOF

    # Copy script to container and run
    docker cp /tmp/3dsg_only.py dovsg-main:/app/
    docker exec dovsg-main conda run -n dovsg python /app/3dsg_only.py "$TAGS"

    # Cleanup
    rm -f /tmp/3dsg_only.py
    docker exec dovsg-main rm -f /app/3dsg_only.py
}

# Main execution
main() {
    cd "$DOCKER_DIR"
    check_container
    check_artifacts
    run_3dsg_pipeline

    echo ""
    echo "✓ 3DSG pipeline completed successfully"
    echo "Interactive viewer should be open with keyboard controls active"
}

# Help text
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [TAGS]"
    echo ""
    echo "Run 3DSG construction and visualization pipeline."
    echo ""
    echo "Arguments:"
    echo "  TAGS    Scene tags (default: room1)"
    echo ""
    echo "Prerequisites:"
    echo "  - Container running: docker-compose up -d"
    echo "  - Preprocessed data: docker exec dovsg-main conda run -n dovsg python demo.py --tags TAGS --preprocess"
    echo ""
    echo "Interactive viewer controls:"
    echo "  B - Toggle background point cloud"
    echo "  C - Color by semantic class"
    echo "  R - Color by RGB appearance"
    echo "  F - Color by CLIP similarity"
    echo "  G - Toggle scene graph relationships"
    echo "  I - Color by instance ID"
    echo "  O - Toggle bounding boxes"
    echo "  V - Save current view parameters"
    exit 0
fi

main "$@"