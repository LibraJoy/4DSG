#!/usr/bin/env python3
"""
Custom RealSense recorder that automatically creates unique directories
Usage: python dovsg/scripts/record_data.py
"""
from realsense_recorder import RecorderImage, RECORDER_DIR
import threading
from datetime import datetime
import os


def record():
    if input("Do you want to record data? [y/n]: ") == "n":
        return

    # Generate unique directory name with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    recorder_dir = RECORDER_DIR / f"recording_{timestamp}"

    print(f"\nData will be saved to: {recorder_dir}")

    # Create recorder with compatible D435i settings
    # Using 640x480 @ 15fps (best balance of speed and quality)
    imagerecorder = RecorderImage(
        recorder_dir=recorder_dir,
        serial_number="215222073770",
        WH=[640, 480],   # Standard resolution, fully supported
        FPS=15,          # Good balance between smoothness and processing
        depth_threshold=[0.3, 3.0]  # 30cm to 3m depth range
    )

    print("\n" + "="*60)
    print("RealSense Camera Ready!")
    print(f"Resolution: {imagerecorder.WH[0]}x{imagerecorder.WH[1]} @ {imagerecorder.FPS} fps")
    print(f"Depth range: {imagerecorder.depth_threshold[0]}m - {imagerecorder.depth_threshold[1]}m")
    print("="*60)

    input("\n\033[32m>>> Press ENTER to START recording...\033[0m")

    record_thread = threading.Thread(target=imagerecorder.start_record)
    record_thread.start()

    input("\n\033[31m>>> Recording in progress. Press ENTER to STOP...\033[0m\n")

    imagerecorder.stop_record()
    record_thread.join()

    print("\nProcessing recorded frames...")
    imagerecorder.change_size()
    imagerecorder.set_metadata()

    # Save calibration file
    intrinsic = imagerecorder.intrinsic
    with open(recorder_dir / "calib.txt", "w") as f:
        f.write(f'{intrinsic.fx} {intrinsic.fy} {intrinsic.ppx} {intrinsic.ppy}')

    num_frames = len(os.listdir(imagerecorder.recorder_dir / 'depth'))

    print("\n" + "="*60)
    print("Recording Complete!")
    print(f"Location: {imagerecorder.recorder_dir}")
    print(f"Frames captured: {num_frames}")
    print(f"Duration: ~{num_frames / imagerecorder.FPS:.1f} seconds")
    print("="*60)

    del imagerecorder


if __name__ == "__main__":
    record()