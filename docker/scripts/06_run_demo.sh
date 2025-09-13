#!/bin/bash

# 06_run_demo.sh
# Easy demo runner with common configurations

set -e

echo "DovSG Demo Runner"
echo "===================="

# Check if containers are running
check_containers_running() {
    if ! docker compose ps | grep -q "Up"; then
        echo "❌ Containers not running!"
        echo "Start them with: ./scripts/05_start_containers.sh"
        exit 1
    fi
    echo "✅ Containers are running"
}

# Check if sample data exists
check_sample_data() {
    if [ -d "../DovSG/data_example/room1" ]; then
        echo "Sample data found"
        return 0
    else
        echo "⚠️  Sample data not found at ../DovSG/data_example/room1"
        echo ""
        echo "Please download sample data from:"
        echo "https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing"
        echo "Extract to: ../DovSG/data_example/room1/"
        echo ""
        read -p "Continue anyway? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Show demo help
show_demo_help() {
    echo ""
    echo "📋 Available demo options:"
    echo "========================="
    echo "1. Basic help (show demo.py options)"
    echo "2. Run DROID-SLAM pose estimation (step 1)"
    echo "3. Show point cloud visualization (step 2)"
    echo "4. Run preprocessing only (step 3)"
    echo "5. Run full demo with sample data (complete pipeline)"
    echo "6. Run custom demo (enter your own parameters)"
    echo "7. Interactive DovSG shell"
    echo "8. Interactive DROID-SLAM shell"
    echo "9. Exit"
    echo ""
}

# Basic help
show_basic_help() {
    echo ""
    echo "🔍 DovSG Demo Help:"
    echo "==================="
    
    docker compose exec dovsg conda run -n dovsg python demo.py --help
}

# Preprocessing only
run_preprocessing() {
    echo ""
    echo "🔄 Running preprocessing only..."
    echo ""
    
    docker compose exec dovsg conda run -n dovsg python demo.py \
        --tags "room1" \
        --preprocess
}

# Full demo
run_full_demo() {
    echo ""
    echo "🎬 Running full demo..."
    echo ""
    
    docker compose exec dovsg conda run -n dovsg python demo.py \
        --tags "room1" \
        --preprocess \
        --debug \
        --task_scene_change_level "Minor Adjustment" \
        --task_description "Please move the red pepper to the plate, then move the green pepper to plate."
}

# Custom demo
run_custom_demo() {
    echo ""
    echo "🛠️  Custom demo parameters:"
    echo ""
    
    read -p "Enter tags (default: room1): " tags
    tags=${tags:-room1}
    
    echo ""
    echo "Options:"
    echo "1. --preprocess (run preprocessing)"
    echo "2. --debug (enable debug mode)"
    echo "3. --scanning_room (scan new room)"
    echo ""
    read -p "Enter additional flags (space-separated): " flags
    
    read -p "Enter task description: " task_desc
    read -p "Enter task scene change level (Minor Adjustment/Major Change): " change_level
    
    echo ""
    echo "Running custom demo..."
    
    cmd="docker compose exec dovsg conda run -n dovsg python demo.py --tags \"$tags\""
    
    if [ -n "$flags" ]; then
        cmd="$cmd $flags"
    fi
    
    if [ -n "$task_desc" ]; then
        cmd="$cmd --task_description \"$task_desc\""
    fi
    
    if [ -n "$change_level" ]; then
        cmd="$cmd --task_scene_change_level \"$change_level\""
    fi
    
    echo "Command: $cmd"
    echo ""
    
    eval $cmd
}

# DROID-SLAM pose estimation using DovSG's script
run_droid_slam() {
    echo ""
    echo "📍 Running DROID-SLAM pose estimation (DovSG method)..."
    echo ""
    
    if [ ! -f "../DovSG/data_example/room1/calib.txt" ]; then
        echo "⚠️  Calibration file not found"
        echo "Expected: ../DovSG/data_example/room1/calib.txt"
        read -p "Continue anyway? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    docker compose exec droid-slam bash -c "cd /app && PYTHONPATH=/app/DROID-SLAM/droid_slam:\$PYTHONPATH conda run -n droidenv python dovsg/scripts/pose_estimation.py \
        --datadir "data_example/room1" \
        --calib "data_example/room1/calib.txt" \
        --t0 0 \
        --stride 1 \
        --weights "checkpoints/droid-slam/droid.pth" \
        --buffer 2048
    "
}

# Show point cloud visualization
show_pointcloud() {
    echo ""
    echo "🔍 Showing point cloud visualization..."
    echo ""
    
    if [ ! -d "../DovSG/data_example/room1/poses_droidslam" ]; then
        echo "⚠️  DROID-SLAM poses not found"
        echo "Please run DROID-SLAM pose estimation first (option 2)"
        return
    fi
    
    docker compose exec dovsg conda run -n dovsg python dovsg/scripts/show_pointcloud.py \
        --tags "room1" \
        --pose_tags "poses_droidslam"
}

# Interactive shells
open_dovsg_shell() {
    echo ""
    echo "🐚 Opening interactive DovSG shell..."
    echo "Commands you can try:"
    echo "  python demo.py --help"
    echo "  python dovsg/scripts/show_pointcloud.py --help"
    echo "  nvidia-smi"
    echo ""
    echo "Type 'exit' to return"
    echo ""
    
    docker compose exec dovsg conda run -n dovsg bash
}

open_droid_shell() {
    echo ""
    echo "🐚 Opening interactive DROID-SLAM shell..."
    echo "Commands you can try:"
    echo "  python /app/DROID-SLAM/demo.py --help"
    echo "  nvidia-smi"
    echo ""
    echo "Type 'exit' to return"
    echo ""
    
    docker compose exec droid-slam conda run -n droidenv bash
}

# Main menu
main() {
    check_containers_running
    check_sample_data
    
    while true; do
        show_demo_help
        read -p "Choose an option (1-9): " choice
        
        case $choice in
            1)
                show_basic_help
                ;;
            2)
                run_droid_slam
                ;;
            3)
                show_pointcloud
                ;;
            4)
                run_preprocessing
                ;;
            5)
                run_full_demo
                ;;
            6)
                run_custom_demo
                ;;
            7)
                open_dovsg_shell
                ;;
            8)
                open_droid_shell
                ;;
            9)
                echo "👋 Exiting"
                break
                ;;
            *)
                echo "❌ Invalid option. Please choose 1-9."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to return to menu..."
    done
}

main "$@"