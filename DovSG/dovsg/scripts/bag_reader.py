#!/usr/bin/env python3
"""
ROS bag reader for DovSG pipeline
Reads ROS bags recorded from RealSense D435i and extracts RGB-D data

Uses rosbags library (pure Python 3, no ROS installation required)
Provides data in the same format as RecorderImage for seamless integration
"""

import numpy as np
import cv2
from pathlib import Path
from typing import Tuple, Optional, Dict
from rosbags.rosbag1 import Reader
from rosbags.serde import deserialize_cdr, ros1_to_cdr
import struct


class BagReader:
    """
    Reads ROS bag files and extracts synchronized RGB-D frames
    Mimics the interface of RecorderImage for compatibility
    """

    def __init__(self, bag_path: str):
        """
        Initialize bag reader

        Args:
            bag_path: Path to ROS bag file
        """
        self.bag_path = Path(bag_path)
        if not self.bag_path.exists():
            raise FileNotFoundError(f"Bag file not found: {bag_path}")

        self.reader = Reader(self.bag_path)
        self.reader.open()

        # Expected topics from RealSense
        self.color_topic = '/camera/color/image_raw'
        self.depth_topic = '/camera/aligned_depth_to_color/image_raw'
        self.camera_info_topic = '/camera/color/camera_info'

        # Extract camera intrinsics
        self.intrinsic_matrix, self.dist_coef, self.intrinsic_dict = self._extract_camera_info()

        # Frame buffers for synchronization
        self.frames = self._extract_all_frames()
        self.frame_index = 0
        self.total_frames = len(self.frames)

        print(f"Loaded bag: {self.bag_path.name}")
        print(f"Total synchronized frames: {self.total_frames}")
        print(f"Intrinsic matrix:\n{self.intrinsic_matrix}")

    def _extract_camera_info(self) -> Tuple[np.ndarray, np.ndarray, dict]:
        """
        Extract camera intrinsics from camera_info topic

        Returns:
            intrinsic_matrix: 3x3 camera matrix
            dist_coef: Distortion coefficients
            intrinsic_dict: Dictionary with fx, fy, ppx, ppy
        """
        connections = [c for c in self.reader.connections if c.topic == self.camera_info_topic]

        if not connections:
            raise ValueError(f"No camera_info topic found in bag: {self.camera_info_topic}")

        # Get first camera_info message
        for connection, timestamp, rawdata in self.reader.messages(connections=connections):
            # Convert ROS1 message to CDR format then deserialize
            cdr_data = ros1_to_cdr(rawdata, connection.msgtype)
            msg = deserialize_cdr(cdr_data, connection.msgtype)

            # Extract intrinsics (K is a 9-element array in row-major order)
            K = np.array(msg.k).reshape(3, 3)
            D = np.array(msg.d)

            # Create intrinsic dict (matches RecorderImage format)
            intrinsic_dict = {
                'fx': K[0, 0],
                'fy': K[1, 1],
                'ppx': K[0, 2],
                'ppy': K[1, 2],
                'width': msg.width,
                'height': msg.height
            }

            return K, D, intrinsic_dict

        raise ValueError("No camera_info messages found in bag")

    def _extract_all_frames(self) -> list:
        """
        Extract and synchronize all RGB-D frames from bag

        Returns:
            List of tuples: (timestamp, color_image, depth_image)
        """
        # Get connections for color and depth topics
        color_conn = [c for c in self.reader.connections if c.topic == self.color_topic]
        depth_conn = [c for c in self.reader.connections if c.topic == self.depth_topic]

        if not color_conn:
            raise ValueError(f"No color topic found: {self.color_topic}")
        if not depth_conn:
            raise ValueError(f"No depth topic found: {self.depth_topic}")

        # Extract all messages with timestamps
        color_msgs = []
        depth_msgs = []

        print("Extracting color images...")
        for connection, timestamp, rawdata in self.reader.messages(connections=color_conn):
            cdr_data = ros1_to_cdr(rawdata, connection.msgtype)
            msg = deserialize_cdr(cdr_data, connection.msgtype)
            color_image = self._decode_image(msg)
            color_msgs.append((timestamp, color_image))

        print("Extracting depth images...")
        for connection, timestamp, rawdata in self.reader.messages(connections=depth_conn):
            cdr_data = ros1_to_cdr(rawdata, connection.msgtype)
            msg = deserialize_cdr(cdr_data, connection.msgtype)
            depth_image = self._decode_depth(msg)
            depth_msgs.append((timestamp, depth_image))

        # Synchronize by timestamp (find closest matches)
        print("Synchronizing RGB-D frames...")
        frames = self._synchronize_frames(color_msgs, depth_msgs)

        return frames

    def _decode_image(self, msg) -> np.ndarray:
        """
        Decode ROS Image message to numpy array

        Args:
            msg: ROS Image message

        Returns:
            Image as numpy array (H x W x C)
        """
        # Handle different encodings
        if msg.encoding == 'bgr8':
            # BGR 8-bit
            img = np.frombuffer(msg.data, dtype=np.uint8).reshape(msg.height, msg.width, 3)
        elif msg.encoding == 'rgb8':
            # RGB 8-bit (convert to BGR for consistency)
            img = np.frombuffer(msg.data, dtype=np.uint8).reshape(msg.height, msg.width, 3)
            img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
        elif msg.encoding == 'mono8':
            # Grayscale 8-bit
            img = np.frombuffer(msg.data, dtype=np.uint8).reshape(msg.height, msg.width)
        else:
            raise ValueError(f"Unsupported image encoding: {msg.encoding}")

        return img

    def _decode_depth(self, msg) -> np.ndarray:
        """
        Decode ROS depth Image message to numpy array

        Args:
            msg: ROS Image message with depth encoding

        Returns:
            Depth array (H x W) in millimeters (uint16)
        """
        if msg.encoding == '16UC1' or msg.encoding == 'mono16':
            # 16-bit unsigned int (standard for RealSense depth)
            depth = np.frombuffer(msg.data, dtype=np.uint16).reshape(msg.height, msg.width)
        elif msg.encoding == '32FC1':
            # 32-bit float (convert to uint16 mm)
            depth_float = np.frombuffer(msg.data, dtype=np.float32).reshape(msg.height, msg.width)
            depth = (depth_float * 1000).astype(np.uint16)  # meters to millimeters
        else:
            raise ValueError(f"Unsupported depth encoding: {msg.encoding}")

        return depth

    def _synchronize_frames(self, color_msgs: list, depth_msgs: list,
                           max_time_diff: int = 50_000_000) -> list:
        """
        Synchronize color and depth frames by timestamp

        Args:
            color_msgs: List of (timestamp, color_image)
            depth_msgs: List of (timestamp, depth_image)
            max_time_diff: Maximum time difference in nanoseconds (default: 50ms)

        Returns:
            List of synchronized (timestamp, color_image, depth_image) tuples
        """
        frames = []
        depth_idx = 0

        for color_ts, color_img in color_msgs:
            # Find closest depth frame
            best_match = None
            best_diff = max_time_diff

            # Search forward from last match
            for i in range(depth_idx, len(depth_msgs)):
                depth_ts, depth_img = depth_msgs[i]
                time_diff = abs(color_ts - depth_ts)

                if time_diff < best_diff:
                    best_diff = time_diff
                    best_match = (depth_ts, depth_img)
                    depth_idx = i
                elif depth_ts > color_ts:
                    # We've passed the color timestamp
                    break

            if best_match is not None:
                frames.append((color_ts, color_img, best_match[1]))

        return frames

    def get_frame(self, index: int) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """
        Get synchronized RGB-D frame by index

        Args:
            index: Frame index

        Returns:
            (color_image, depth_image) or None if index out of range
        """
        if index < 0 or index >= self.total_frames:
            return None

        timestamp, color_img, depth_img = self.frames[index]
        return color_img, depth_img

    def get_next_frame(self) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """
        Get next frame in sequence

        Returns:
            (color_image, depth_image) or None if end reached
        """
        if self.frame_index >= self.total_frames:
            return None

        frame = self.get_frame(self.frame_index)
        self.frame_index += 1
        return frame

    def compute_pointcloud(self, depth: np.ndarray) -> np.ndarray:
        """
        Compute 3D point cloud from depth image
        Uses same approach as RecorderImage

        Args:
            depth: Depth image in millimeters (H x W)

        Returns:
            Point cloud (H x W x 3) in meters
        """
        height, width = depth.shape

        # Create pixel grid
        i_coords, j_coords = np.meshgrid(np.arange(height), np.arange(width), indexing='ij')

        # Get intrinsics
        fx = self.intrinsic_matrix[0, 0]
        fy = self.intrinsic_matrix[1, 1]
        cx = self.intrinsic_matrix[0, 2]
        cy = self.intrinsic_matrix[1, 2]

        # Convert depth to meters
        z = depth.astype(np.float32) / 1000.0

        # Deproject to 3D (pinhole camera model)
        x = (j_coords - cx) * z / fx
        y = (i_coords - cy) * z / fy

        # Stack to point cloud
        points = np.stack([x, y, z], axis=-1)

        return points

    def close(self):
        """Close bag file"""
        if hasattr(self, 'reader'):
            self.reader.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    def __len__(self):
        return self.total_frames


def test_bag_reader(bag_path: str):
    """
    Test bag reader functionality

    Args:
        bag_path: Path to test bag file
    """
    print(f"Testing bag reader with: {bag_path}\n")

    with BagReader(bag_path) as reader:
        print(f"\nCamera intrinsics:")
        print(f"  fx: {reader.intrinsic_dict['fx']:.2f}")
        print(f"  fy: {reader.intrinsic_dict['fy']:.2f}")
        print(f"  cx: {reader.intrinsic_dict['ppx']:.2f}")
        print(f"  cy: {reader.intrinsic_dict['ppy']:.2f}")
        print(f"  Resolution: {reader.intrinsic_dict['width']}x{reader.intrinsic_dict['height']}")

        # Test reading first frame
        color, depth = reader.get_frame(0)
        if color is not None:
            print(f"\nFirst frame:")
            print(f"  Color shape: {color.shape}, dtype: {color.dtype}")
            print(f"  Depth shape: {depth.shape}, dtype: {depth.dtype}")
            print(f"  Depth range: {depth.min()}-{depth.max()} mm")

            # Test point cloud computation
            points = reader.compute_pointcloud(depth)
            print(f"  Point cloud shape: {points.shape}")
            print(f"  Point range: {points[points[:,:,2] > 0].min():.3f} - {points.max():.3f} m")


if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        test_bag_reader(sys.argv[1])
    else:
        print("Usage: python bag_reader.py <path_to_bag_file>")
