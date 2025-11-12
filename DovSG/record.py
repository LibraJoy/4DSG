#!/usr/bin/env python3
"""
Custom RealSense recorder that automatically creates unique directories
Supports both live camera recording and ROS bag processing

Usage:
    Live recording: python record.py
    Bag processing: python record.py --from-bag <bag_file> [--output-dir <dir>]
"""
from dovsg.scripts.realsense_recorder import RecorderImage
from dovsg.scripts.bag_reader import BagReader
from dovsg.utils.utils import RECORDER_DIR
import threading
from datetime import datetime
import os
import argparse
from pathlib import Path
import numpy as np
import cv2
from tqdm import tqdm


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


def process_bag(bag_file, output_dir=None):
    """
    Process ROS bag file and convert to DovSG data format

    Args:
        bag_file: Path to ROS bag file
        output_dir: Output directory (default: auto-generated)
    """
    bag_path = Path(bag_file)
    if not bag_path.exists():
        print(f"Error: Bag file not found: {bag_file}")
        return

    # Generate output directory
    if output_dir is None:
        bag_name = bag_path.stem  # Get filename without extension
        output_dir = RECORDER_DIR / bag_name
    else:
        output_dir = Path(output_dir)

    print(f"\nProcessing: {bag_path.name}")
    print(f"Output: {output_dir}")

    if output_dir.exists():
        if input("Output directory exists. Overwrite? [y/n]: ") != "y":
            return
        import shutil
        shutil.rmtree(output_dir)

    # Create output directories
    os.makedirs(output_dir / "depth", exist_ok=True)
    os.makedirs(output_dir / "rgb", exist_ok=True)
    os.makedirs(output_dir / "point", exist_ok=True)
    os.makedirs(output_dir / "mask", exist_ok=True)
    os.makedirs(output_dir / "calibration", exist_ok=True)

    # Read bag file
    with BagReader(bag_file) as reader:
        total_frames = len(reader)
        print(f"Frames: {total_frames}")

        # Extract camera parameters
        intrinsic_matrix = reader.intrinsic_matrix
        dist_coef = reader.dist_coef
        intrinsic_dict = reader.intrinsic_dict

        # Depth scale (RealSense typically uses mm, same as RecorderImage)
        depth_scale = 0.001  # mm to meters

        # Process each frame
        for frame_idx in tqdm(range(total_frames), desc="Converting"):
            color, depth = reader.get_frame(frame_idx)

            if color is None or depth is None:
                continue

            # Compute point cloud
            points = reader.compute_pointcloud(depth)

            # Create mask (valid depth range: 0.3m - 3.0m, matching record.py)
            depth_min_mm = 300  # 0.3m in mm
            depth_max_mm = 3000  # 3.0m in mm
            mask = np.logical_and(depth > depth_min_mm, depth < depth_max_mm)

            # Crop to match record.py output (600 height, removes bottom 120px if 720)
            height = color.shape[0]
            if height > 600:
                crop_height = 600
                color = color[:crop_height, :, :]
                depth = depth[:crop_height, :]
                points = points[:crop_height, :, :]
                mask = mask[:crop_height, :]

            # Save files (matching RecorderImage format)
            color_path = output_dir / "rgb" / f"{frame_idx:06}.jpg"
            depth_path = output_dir / "depth" / f"{frame_idx:06}.npy"
            point_path = output_dir / "point" / f"{frame_idx:06}.npy"
            mask_path = output_dir / "mask" / f"{frame_idx:06}.npy"
            calib_path = output_dir / "calibration" / f"{frame_idx:06}.txt"

            cv2.imwrite(str(color_path), color, [cv2.IMWRITE_JPEG_QUALITY, 100])
            np.save(str(depth_path), depth)
            np.save(str(point_path), points)
            np.save(str(mask_path), mask)
            np.savetxt(str(calib_path), intrinsic_matrix)

        # Save metadata (matching RecorderImage.set_metadata)
        final_height, final_width = color.shape[:2]
        metadata = {
            "w": final_width,
            "h": final_height,
            "dw": final_width,
            "dh": final_height,
            "fps": 15,  # Assuming 15 fps (from recording settings)
            "K": intrinsic_matrix.tolist(),
            "depth_scale": depth_scale,
            "min_depth": 0.3,  # meters
            "max_depth": 3.0,  # meters
            "cameraType": 1,
            "dist_coef": dist_coef.tolist(),
            "length": total_frames
        }

        import json
        with open(output_dir / "metadata.json", "w") as f:
            json.dump(metadata, f, indent=4)

        # Save calibration file (matching record.py format)
        with open(output_dir / "calib.txt", "w") as f:
            f.write(f"{intrinsic_dict['fx']} {intrinsic_dict['fy']} "
                   f"{intrinsic_dict['ppx']} {intrinsic_dict['ppy']}")

    print(f"\n✓ Complete! Processed {total_frames} frames → {output_dir}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Record or process RealSense D435i data",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Live recording:
    python record.py

  Process ROS bag:
    python record.py --from-bag recording_20250110_143022.bag
    python record.py --from-bag mybag.bag --output-dir data_example/room2
        """
    )
    parser.add_argument('--from-bag', type=str, help='Process data from ROS bag file')
    parser.add_argument('--output-dir', type=str, help='Output directory (default: auto-generated)')

    args = parser.parse_args()

    if args.from_bag:
        # Process bag mode
        process_bag(args.from_bag, args.output_dir)
    else:
        # Live recording mode
        record()