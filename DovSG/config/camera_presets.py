"""
Camera preset configurations for RealSense D455.

This module provides two preset configurations for different use cases:
- OPTIMIZED: Tuned for D455 with better SLAM accuracy and lower storage
- ORIGINAL: Legacy DovSG settings for backward compatibility

PARAMETER AUTO-LOADING STATUS:
===================================

AUTO-LOADED by record.py:
  - serial_number, width, height, fps (passed to RecorderImage)
  - depth_min, depth_max (passed as depth_threshold)

AUTO-LOADED by record_rosbag.py:
  - NONE (always records at 1280x720@30fps for archival quality)

MANUAL EDIT REQUIRED (Reference Only):
  - spatial_filter, temporal_filter: See instructions below
  - real_width, real_height: Hardcoded in realsense_recorder.py
  - slam: Used by pose_estimation.py, not recording scripts

FILTER PARAMETER MANUAL EDIT INSTRUCTIONS:
===========================================

The filter parameters below are REFERENCE values only.
To actually apply them, you must manually edit:

  File: DovSG/dovsg/scripts/realsense_recorder.py
  Method: RecorderImage._init_depth_process()
  Lines: 74-81

Current hardcoded values (lines 74-81):
  self.spatial.set_option(rs.option.filter_magnitude, 5)
  self.spatial.set_option(rs.option.filter_smooth_alpha, 0.75)
  self.spatial.set_option(rs.option.filter_smooth_delta, 1)
  self.spatial.set_option(rs.option.holes_fill, 1)
  self.temporal.set_option(rs.option.filter_smooth_alpha, 0.75)
  self.temporal.set_option(rs.option.filter_smooth_delta, 1)

To use OPTIMIZED preset filters, change to:
  self.spatial.set_option(rs.option.filter_magnitude, 2)
  self.spatial.set_option(rs.option.filter_smooth_alpha, 0.5)
  self.spatial.set_option(rs.option.filter_smooth_delta, 20)
  self.spatial.set_option(rs.option.holes_fill, 3)
  self.temporal.set_option(rs.option.filter_smooth_alpha, 0.5)
  self.temporal.set_option(rs.option.filter_smooth_delta, 20)

Note: realsense_recorder.py is the original DovSG code kept as reference.
      Filters are applied during direct recording only (not ROS bag workflow).
"""

PRESETS = {
    "OPTIMIZED": {
        # ============ AUTO-LOADED PARAMETERS ============

        # Camera settings - D455 optimized resolution
        # AUTO-LOADED by: record.py (passed to RecorderImage)
        "serial_number": "318122303885",
        "width": 848,
        "height": 480,
        "fps": 30,

        # Depth range (meters) - D455 optimal range
        # AUTO-LOADED by: record.py (passed as depth_threshold)
        "depth_min": 0.4,
        "depth_max": 3.5,

        # ============ REFERENCE-ONLY PARAMETERS ============
        # These are NOT auto-loaded. See documentation above for manual edit instructions.

        # Crop dimensions (hardcoded in realsense_recorder.py lines 18-19)
        "real_width": 848,
        "real_height": 480,

        # Depth filters - REFERENCE ONLY (requires manual edit)
        # Optimized for D455's wider baseline (95mm)
        # To apply: Edit realsense_recorder.py lines 74-81 (see instructions above)
        "spatial_filter": {
            "magnitude": 2,        # Less aggressive smoothing (D455 has better depth quality)
            "smooth_alpha": 0.5,   # Moderate smoothing
            "smooth_delta": 20,    # Higher threshold (more selective filtering)
            "holes_fill": 3        # Fill small holes only
        },
        "temporal_filter": {
            "smooth_alpha": 0.5,   # Moderate temporal smoothing
            "smooth_delta": 20     # Higher threshold
        },

        # DROID-SLAM parameters - REFERENCE ONLY
        # Used by: DovSG/dovsg/scripts/pose_estimation.py (NOT recording scripts)
        # Tuned for 848x480@30fps
        "slam": {
            "keyframe_thresh": 3.0,   # Slightly lower threshold (more keyframes for 30fps)
            "frontend_thresh": 12.0,  # Balanced tracking
            "beta": 0.4,              # Moderate damping
            "buffer": 2048,           # Same buffer size
            "warmup": 8,              # Default warmup
            "stride": 1               # Process every frame at 30fps
        },

        # Storage estimate
        "storage_gb_per_min": 7,

        # Description
        "description": "Optimized for D455 - Better SLAM accuracy with lower storage requirements"
    },

    "ORIGINAL": {
        # ============ AUTO-LOADED PARAMETERS ============

        # Camera settings - Original DovSG configuration
        # AUTO-LOADED by: record.py (passed to RecorderImage)
        "serial_number": "318122303885",
        "width": 1280,
        "height": 720,
        "fps": 30,

        # Depth range (meters) - Original settings
        # AUTO-LOADED by: record.py (passed as depth_threshold)
        "depth_min": 0.0,
        "depth_max": 2.0,

        # ============ REFERENCE-ONLY PARAMETERS ============
        # These are NOT auto-loaded. See documentation at top of file.

        # Crop dimensions (hardcoded in realsense_recorder.py lines 18-19)
        "real_width": 1200,  # Cropped from 1280
        "real_height": 600,  # Cropped from 720

        # Depth filters - REFERENCE ONLY (requires manual edit)
        # Original DovSG settings (currently active in realsense_recorder.py)
        # These match the current hardcoded values in realsense_recorder.py lines 74-81
        "spatial_filter": {
            "magnitude": 5,
            "smooth_alpha": 0.75,
            "smooth_delta": 1,
            "holes_fill": 1
        },
        "temporal_filter": {
            "smooth_alpha": 0.75,
            "smooth_delta": 1
        },

        # DROID-SLAM parameters - REFERENCE ONLY
        # Used by: DovSG/dovsg/scripts/pose_estimation.py (NOT recording scripts)
        # Original defaults
        "slam": {
            "keyframe_thresh": 4.0,
            "frontend_thresh": 16.0,
            "beta": 0.3,
            "buffer": 2048,
            "warmup": 8,
            "stride": 1
        },

        # Storage estimate
        "storage_gb_per_min": 16,

        # Description
        "description": "Original DovSG settings - Legacy configuration for backward compatibility"
    }
}


def get_preset(preset_name="OPTIMIZED"):
    """
    Get camera preset configuration.

    Args:
        preset_name: Name of preset ("OPTIMIZED" or "ORIGINAL")

    Returns:
        Dictionary containing preset configuration

    Raises:
        ValueError: If preset_name is not recognized
    """
    if preset_name not in PRESETS:
        available = ", ".join(PRESETS.keys())
        raise ValueError(f"Unknown preset '{preset_name}'. Available presets: {available}")

    return PRESETS[preset_name]


def print_preset_info(preset_name):
    """Print detailed information about a preset configuration."""
    preset = get_preset(preset_name)

    print(f"\n{'='*70}")
    print(f"Camera Preset: {preset_name}")
    print(f"{'='*70}")
    print(f"\nCamera Settings:")
    print(f"  Serial Number: {preset['serial_number']}")
    print(f"  Resolution: {preset['width']}x{preset['height']} @ {preset['fps']}fps")
    print(f"  Output Size: {preset['real_width']}x{preset['real_height']}")
    print(f"  Depth Range: {preset['depth_min']}m - {preset['depth_max']}m")
    print(f"\nDepth Filters:")
    print(f"  Spatial: magnitude={preset['spatial_filter']['magnitude']}, "
          f"alpha={preset['spatial_filter']['smooth_alpha']}, "
          f"delta={preset['spatial_filter']['smooth_delta']}, "
          f"holes_fill={preset['spatial_filter']['holes_fill']}")
    print(f"  Temporal: alpha={preset['temporal_filter']['smooth_alpha']}, "
          f"delta={preset['temporal_filter']['smooth_delta']}")
    print(f"\nSLAM Parameters:")
    print(f"  Keyframe Threshold: {preset['slam']['keyframe_thresh']}")
    print(f"  Frontend Threshold: {preset['slam']['frontend_thresh']}")
    print(f"  Beta (Damping): {preset['slam']['beta']}")
    print(f"  Buffer Size: {preset['slam']['buffer']}")
    print(f"{'='*70}\n")


if __name__ == "__main__":
    # Print information about both presets
    print_preset_info("OPTIMIZED")
    print_preset_info("ORIGINAL")
