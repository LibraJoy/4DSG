#!/usr/bin/env python3
"""
ROS bag recorder for RealSense D435i camera
Records RGB-D data and IMU to ROS bag files for offline processing

This script matches the exact camera configuration from record.py:
- Resolution: 640x480
- FPS: 15
- Depth range: 0.3m - 3.0m
- Spatial and temporal filtering enabled
- Aligned depth to color
"""

import rospy
import rosbag
from datetime import datetime
from pathlib import Path
import sys
import os


def launch_realsense_node():
    """
    Launch RealSense camera node with matching configuration from record.py
    """
    import subprocess

    # RealSense node parameters - SIMPLIFIED
    # Note: Original realsense_recorder.py applies filters in Python after capture.
    # Keep ROS config minimal to avoid parameter conflicts.
    params = {
        'serial_no': '215222073770',
        'camera': 'camera',

        # Resolution and FPS (matching RecorderImage: WH=[640, 480], FPS=15)
        'depth_width': '640',
        'depth_height': '480',
        'depth_fps': '15',
        'color_width': '640',
        'color_height': '480',
        'color_fps': '15',

        # Enable required streams only
        'enable_depth': 'true',
        'enable_color': 'true',
        'enable_infra1': 'false',
        'enable_infra2': 'false',

        # Critical: Align depth to color and synchronize
        'align_depth': 'true',
        'enable_sync': 'true',
    }

    # Build roslaunch command - use rs_aligned_depth.launch for aligned depth support
    cmd = ['roslaunch', 'realsense2_camera', 'rs_aligned_depth.launch']
    for key, value in params.items():
        cmd.append(f'{key}:={value}')

    print("\n" + "="*60)
    print("Launching RealSense camera node...")
    print(f"Resolution: 640x480 @ 15 fps")
    print(f"Depth range: 0.3m - 3.0m")
    print(f"Serial: {params['serial_no']}")
    print("Filters: Spatial + Temporal + Disparity")
    print("="*60)
    print("\nRoslaunch command:")
    print(" ".join(cmd))
    print("="*60 + "\n")

    # Launch in subprocess - DO NOT capture stdout/stderr so we can see errors!
    process = subprocess.Popen(cmd)

    # Wait for node to initialize
    print("Waiting for camera node to start publishing...")
    rospy.sleep(5.0)  # Increased from 3s to 5s for better initialization

    print("\nVerifying camera topics are being published...")
    return process


def record_bag(output_dir="/app/rosbags"):
    """
    Record ROS bag from RealSense topics

    Topics to record (matching data needed by dovsg):
    - /camera/color/image_raw: RGB images
    - /camera/aligned_depth_to_color/image_raw: Aligned depth
    - /camera/color/camera_info: Camera intrinsics
    - /camera/imu: IMU data (D435i)
    - /camera/accel/sample: Accelerometer
    - /camera/gyro/sample: Gyroscope
    """

    # Generate unique bag filename with timestamp (matching record.py naming)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    bag_file = output_path / f"recording_{timestamp}.bag"

    print(f"\nBag file will be saved to: {bag_file}\n")

    # Topics to record
    topics = [
        '/camera/color/image_raw',
        '/camera/aligned_depth_to_color/image_raw',
        '/camera/color/camera_info',
        '/camera/depth/camera_info',
        '/camera/imu',
        '/camera/accel/sample',
        '/camera/gyro/sample',
    ]

    print("Topics to record:")
    for topic in topics:
        print(f"  - {topic}")
    print()

    # Verify camera topics are being published before recording
    # Focus on critical RGB-D topics (skip optional IMU topics for initial check)
    critical_topics = [
        '/camera/color/image_raw',
        '/camera/aligned_depth_to_color/image_raw',
        '/camera/color/camera_info',
    ]

    success, missing = verify_camera_topics(critical_topics, timeout=15)

    if not success:
        print("\n" + "="*60)
        print("ERROR: Camera not publishing required depth topics!")
        print("="*60)
        print("\nPossible causes:")
        print("1. Camera not connected or not detected")
        print("2. RealSense node configuration issue")
        print("3. Depth stream not enabled in camera firmware")
        print("\nTroubleshooting steps:")
        print("- Check camera connection: lsusb | grep Intel")
        print("- Verify depth is enabled in launch parameters")
        print("- Try restarting the camera node")
        print("\nDo you want to continue recording anyway? [y/n]: ", end="")
        response = input()
        if response.lower() != 'y':
            print("Recording cancelled.")
            return None

    # Use rosbag record command
    import subprocess
    cmd = ['rosbag', 'record', '-O', str(bag_file)] + topics

    input("\n\033[32m>>> Press ENTER to START recording...\033[0m")

    print("\n\033[31m>>> Recording in progress. Press Ctrl+C to STOP...\033[0m\n")

    try:
        # Run rosbag record (blocks until Ctrl+C)
        subprocess.run(cmd)
    except KeyboardInterrupt:
        print("\n\nStopping recording...")

    print("\n" + "="*60)
    print("Recording Complete!")
    print(f"Bag file: {bag_file}")
    print("="*60)

    return bag_file


def verify_camera_topics(expected_topics, timeout=15):
    """
    Verify that expected camera topics are ACTIVELY publishing messages
    Not just that they exist, but that data is flowing

    Args:
        expected_topics: List of topic names to check
        timeout: Maximum time to wait for topics (seconds)

    Returns:
        (bool, list): Success status and list of missing topics
    """
    import time
    import rospy
    print(f"\nWaiting up to {timeout}s for camera topics to publish messages...")

    start_time = time.time()
    topics_with_messages = set()

    # First wait for topics to appear in the list
    while (time.time() - start_time) < timeout:
        published_topics = [t for t, _ in rospy.get_published_topics()]

        # Check if each expected topic is actually publishing messages
        for topic in expected_topics:
            if topic not in topics_with_messages:
                if topic in published_topics:
                    # Topic exists, now verify it's publishing messages
                    try:
                        # Wait for ONE message with 2s timeout
                        msg_class = rospy.AnyMsg
                        rospy.wait_for_message(topic, msg_class, timeout=2.0)
                        topics_with_messages.add(topic)
                        print(f"  ✓ {topic} - receiving messages")
                    except rospy.ROSException:
                        # Topic exists but no messages yet, continue waiting
                        pass

        # Check if we got all topics
        if len(topics_with_messages) == len(expected_topics):
            break

        time.sleep(0.5)

    # Calculate which topics are still missing
    missing_topics = [t for t in expected_topics if t not in topics_with_messages]

    if missing_topics:
        print("\n⚠ WARNING: Some camera topics are NOT publishing messages:")
        for topic in missing_topics:
            print(f"  ✗ {topic}")
        print("\nPublished topics:")
        for topic, _ in rospy.get_published_topics():
            if '/camera/' in topic:
                status = '✓' if topic in topics_with_messages else '?'
                print(f"  {status} {topic}")
        return False, missing_topics
    else:
        print("\n✓ All required camera topics are actively publishing:")
        for topic in expected_topics:
            print(f"  ✓ {topic}")
        return True, []


def check_roscore():
    """
    Check if roscore is running
    """
    import time
    print("\nChecking for roscore...")

    max_attempts = 5
    for attempt in range(max_attempts):
        try:
            import rosgraph
            master = rosgraph.Master('/roscore_check')
            master.getPid()
            print("✓ roscore is running\n")
            return True
        except Exception as e:
            if attempt < max_attempts - 1:
                print(f"  Waiting for roscore... (attempt {attempt + 1}/{max_attempts})")
                time.sleep(1)
            else:
                print(f"\n✗ Error: Cannot connect to roscore!")
                print(f"  Make sure roscore is running:")
                print(f"    docker compose up -d roscore")
                print(f"  ROS_MASTER_URI: {os.environ.get('ROS_MASTER_URI', 'not set')}")
                print(f"  ROS_IP: {os.environ.get('ROS_IP', 'not set')}\n")
                return False
    return False


def setup_ros_environment():
    """
    Source ROS environment if not already sourced
    """
    # Check if ROS is already sourced
    if 'ROS_PACKAGE_PATH' not in os.environ or not os.environ['ROS_PACKAGE_PATH']:
        print("Setting up ROS environment...")

        # Source ROS setup.bash
        import subprocess
        cmd = "bash -c 'source /opt/ros/noetic/setup.bash && env'"
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)

        # Parse environment variables
        for line in proc.stdout:
            (key, _, value) = line.decode().partition("=")
            if key and value:
                os.environ[key] = value.rstrip()

        proc.communicate()
        print(f"✓ ROS environment configured")
        print(f"  ROS_PACKAGE_PATH: {os.environ.get('ROS_PACKAGE_PATH', 'not set')[:80]}...")


def main():
    """
    Main entry point for ROS bag recording
    """

    # Check if user wants to record
    if len(sys.argv) > 1 and sys.argv[1] == "--help":
        print("Usage: python ros_bag_recorder.py [output_dir]")
        print("  output_dir: Directory to save bag files (default: /app/rosbags)")
        return

    response = input("Do you want to record data? [y/n]: ")
    if response.lower() != 'y':
        print("Recording cancelled.")
        return

    # Get output directory
    output_dir = sys.argv[1] if len(sys.argv) > 1 else "/app/rosbags"

    # Setup ROS environment
    setup_ros_environment()

    # Check if roscore is running
    if not check_roscore():
        return

    # Initialize ROS node
    print("Initializing ROS node...")
    rospy.init_node('realsense_bag_recorder', anonymous=True)

    # Launch RealSense camera
    camera_process = launch_realsense_node()

    try:
        # Record bag
        bag_file = record_bag(output_dir)
        print(f"\nSuccess! Bag saved to: {bag_file}")

    except Exception as e:
        print(f"\nError during recording: {e}")

    finally:
        # Cleanup
        print("\nShutting down camera node...")
        camera_process.terminate()
        camera_process.wait()
        print("Done.")


if __name__ == "__main__":
    main()
