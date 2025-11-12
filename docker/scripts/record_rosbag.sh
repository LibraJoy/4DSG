#!/bin/bash
# Helper script to record ROS bags from RealSense D435i camera
# Usage: ./scripts/record_rosbag.sh [output_dir]

set -e

OUTPUT_DIR="${1:-/app/rosbags}"

echo "This will record RGB-D data from RealSense D435i to a ROS bag file."
echo "Output directory: $OUTPUT_DIR"
echo ""

# Run the recording script
echo ""
echo "Launching ROS bag recorder..."
docker compose exec realsense-recorder bash -c "cd /app && python3 scripts/ros_bag_recorder.py $OUTPUT_DIR"

echo ""
echo "Recording session complete!"
echo ""
