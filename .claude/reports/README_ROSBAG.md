# ROS Bag Recording and Processing Guide

This guide explains the two-stage data collection workflow for DovSG.

## Overview

The new workflow decouples data recording from processing:

1. **Stage 1 (Recording)**: Use a lightweight ROS Noetic container to record ROS bags from RealSense D435i
2. **Stage 2 (Processing)**: Use the main DovSG container to convert ROS bags to DovSG data format offline

## Prerequisites

- RealSense D435i camera connected via USB
- Docker and Docker Compose installed
- Containers built: `cd docker && ./scripts/docker_build.sh`

## Stage 1: Recording ROS Bags

### Quick Start

```bash
cd docker/
./scripts/record_rosbag.sh
```

This will:
1. Start roscore
2. Start the realsense-recorder container
3. Launch the recording script
4. Prompt you to start/stop recording
5. Save the ROS bag to `DovSG/data_example/`

### Manual Recording

```bash
cd docker/

# Start services
docker compose up -d roscore realsense-recorder

# Run recording script
docker compose exec realsense-recorder python3 scripts/ros_bag_recorder.py /app/rosbags

# Follow prompts to start/stop recording
```

### Camera Settings

The recorder uses these settings (matching the original record.py):
- Resolution: 640x480
- Frame rate: 15 fps
- Depth range: 0.3m - 3.0m
- Filters: Spatial + Temporal + Disparity
- Depth aligned to color

### Recorded Topics

The ROS bag contains:
- `/camera/color/image_raw` - RGB images
- `/camera/aligned_depth_to_color/image_raw` - Aligned depth
- `/camera/color/camera_info` - Camera intrinsics
- `/camera/imu` - IMU data
- `/camera/accel/sample` - Accelerometer
- `/camera/gyro/sample` - Gyroscope

## Stage 2: Processing ROS Bags

### Convert Bag to DovSG Format

```bash
cd docker/

# Process with auto-generated output directory
docker compose exec dovsg python dovsg/scripts/record.py \
    --from-bag data_example/recording_20250110_143022.bag

# Specify custom output directory
docker compose exec dovsg python dovsg/scripts/record.py \
    --from-bag data_example/recording_20250110_143022.bag \
    --output-dir data_example/room2
```

### Output Structure

The processing creates a DovSG data example with this structure:

```
data_example/recording_YYYYMMDD_HHMMSS/
├── rgb/               # JPEG images
├── depth/             # NumPy depth arrays (uint16, mm)
├── point/             # NumPy point clouds (H x W x 3, meters)
├── mask/              # Valid depth masks (H x W, boolean)
├── calibration/       # Per-frame intrinsic matrices
├── calib.txt          # Camera intrinsics (fx fy cx cy)
└── metadata.json      # Recording metadata
```

This format is identical to the original live recording format.

## Running the Full Pipeline

After processing a bag, run the DovSG pipeline as usual:

```bash
cd docker/

# Full preprocessing
docker compose exec dovsg python -u demo.py \
    --tags "recording_20250110_143022" \
    --preprocess \
    --debug \
    --skip_task_planning

# 3DSG-only (if preprocessing already done)
./scripts/run_3dsg_only.sh recording_20250110_143022
```

## Troubleshooting

### Camera Not Detected

If the RealSense camera is not detected:

```bash
# Check USB devices
docker compose exec realsense-recorder lsusb | grep Intel

# Check RealSense SDK
docker compose exec realsense-recorder rs-enumerate-devices
```

### ROS Topics Not Publishing

```bash
# Check ROS topics
docker compose exec realsense-recorder bash -c "source /opt/ros/noetic/setup.bash && rostopic list"

# Monitor camera info
docker compose exec realsense-recorder bash -c "source /opt/ros/noetic/setup.bash && rostopic echo /camera/color/camera_info -n 1"
```

### Bag File Inspection

```bash
# Check bag contents
docker compose exec dovsg python -c "
from bag_reader import BagReader
reader = BagReader('data_example/recording_20250110_143022.bag')
print(f'Frames: {len(reader)}')
print(f'Intrinsics: {reader.intrinsic_dict}')
"
```

### Processing Errors

Common issues:
- **No camera_info topic**: Bag was not recorded with proper topics
- **Timestamp sync issues**: Set `max_time_diff` in `bag_reader.py` (default: 50ms)
- **Memory issues**: Process in batches by modifying `process_bag()` function

## Advantages of ROS Bag Workflow

1. **Portability**: Share datasets as standard ROS bags
2. **Reliability**: Re-process without re-recording
3. **Debugging**: Inspect raw sensor data before processing
4. **Flexibility**: Process with different parameters
5. **Lightweight recording**: No GPU needed for recording

## Backward Compatibility

The original live recording workflow still works:

```bash
cd docker/
docker compose exec dovsg python dovsg/scripts/record.py
```

Both workflows produce identical DovSG data format.

## Advanced Usage

### Custom Bag Location

```bash
# Record to custom location
docker compose exec realsense-recorder python3 scripts/ros_bag_recorder.py /custom/path

# Process from custom location
docker compose exec dovsg python dovsg/scripts/record.py \
    --from-bag /custom/path/mybag.bag
```

### Batch Processing

Process multiple bags:

```bash
for bag in data_example/*.bag; do
    echo "Processing $bag..."
    docker compose exec dovsg python dovsg/scripts/record.py --from-bag "$bag"
done
```

### Testing Bag Reader

```bash
# Test reading a bag file
docker compose exec dovsg python dovsg/scripts/bag_reader.py data_example/recording_20250110_143022.bag
```

## Notes

- ROS bags can be large (several GB for a few minutes of recording)
- Processing time depends on bag size and frame count
- GPU not required for bag recording, only for processing
- Bags can be compressed: `rosbag compress mybag.bag`
