#!/bin/bash
# Helper script to record high-quality ROS bags from RealSense D455 camera
# Usage: ./scripts/record_rosbag.sh [output_dir]

set -e

OUTPUT_DIR="${1:-/app/rosbags}"

echo "=================================================="
echo "RealSense D455 - High Quality ROS Bag Recording"
echo "=================================================="
echo "Resolution: 1280x720 @ 30 fps (archival quality)"
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Note: Choose processing quality later with:"
echo "  python record.py --from-bag <bag> --preset OPTIMIZED"
echo "  python record.py --from-bag <bag> --preset ORIGINAL"
echo "=================================================="
echo ""

# Run the recording script
docker compose exec realsense-recorder bash -c "cd /app && python3 record_rosbag.py --output $OUTPUT_DIR"

echo ""
echo "Recording session complete!"
echo ""
