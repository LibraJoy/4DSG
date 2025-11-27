cerlab@cerlab22:~/4DSG/docker$ ./scripts/record_rosbag.sh 
This will record RGB-D data from RealSense D435i to a ROS bag file.
Output directory: /app/rosbags


Launching ROS bag recorder...
Do you want to record data? [y/n]: y
Setting up ROS environment...
✓ ROS environment configured
  ROS_PACKAGE_PATH: /opt/ros/noetic/share...

Checking for roscore...
✓ roscore is running

Initializing ROS node...

============================================================
Launching RealSense camera node...
Resolution: 640x480 @ 15 fps
Depth range: 0.3m - 3.0m
Serial: 215222073770
Filters: Spatial + Temporal + Disparity
============================================================

Roslaunch command:
roslaunch realsense2_camera rs_aligned_depth.launch serial_no:=215222073770 camera:=camera depth_width:=640 depth_height:=480 depth_fps:=15 color_width:=640 color_height:=480 color_fps:=15 enable_depth:=true enable_color:=true enable_infra1:=false enable_infra2:=false align_depth:=true enable_sync:=true
============================================================

Waiting for camera node to start publishing...
... logging to /root/.ros/log/57e7fd8c-bfde-11f0-aed0-6c02e04fde8e/roslaunch-cerlab22-55.log
Checking log directory for disk usage. This may take a while.
Press Ctrl-C to interrupt
Done checking log file disk usage. Usage is <1GB.

started roslaunch server http://172.24.44.111:46833/

SUMMARY
========

PARAMETERS
 * /camera/realsense2_camera/accel_fps: 250
 * /camera/realsense2_camera/accel_frame_id: camera_accel_frame
 * /camera/realsense2_camera/accel_optical_frame_id: camera_accel_opti...
 * /camera/realsense2_camera/align_depth: True
 * /camera/realsense2_camera/aligned_depth_to_color_frame_id: camera_aligned_de...
 * /camera/realsense2_camera/aligned_depth_to_fisheye1_frame_id: camera_aligned_de...
 * /camera/realsense2_camera/aligned_depth_to_fisheye2_frame_id: camera_aligned_de...
 * /camera/realsense2_camera/aligned_depth_to_fisheye_frame_id: camera_aligned_de...
 * /camera/realsense2_camera/aligned_depth_to_infra1_frame_id: camera_aligned_de...
 * /camera/realsense2_camera/aligned_depth_to_infra2_frame_id: camera_aligned_de...
 * /camera/realsense2_camera/allow_no_texture_points: False
 * /camera/realsense2_camera/base_frame_id: camera_link
 * /camera/realsense2_camera/calib_odom_file: 
 * /camera/realsense2_camera/clip_distance: -1.0
 * /camera/realsense2_camera/color_fps: 15
 * /camera/realsense2_camera/color_frame_id: camera_color_frame
 * /camera/realsense2_camera/color_height: 480
 * /camera/realsense2_camera/color_optical_frame_id: camera_color_opti...
 * /camera/realsense2_camera/color_width: 640
 * /camera/realsense2_camera/confidence_fps: 30
 * /camera/realsense2_camera/confidence_height: 480
 * /camera/realsense2_camera/confidence_width: 640
 * /camera/realsense2_camera/depth_fps: 15
 * /camera/realsense2_camera/depth_frame_id: camera_depth_frame
 * /camera/realsense2_camera/depth_height: 480
 * /camera/realsense2_camera/depth_optical_frame_id: camera_depth_opti...
 * /camera/realsense2_camera/depth_width: 640
 * /camera/realsense2_camera/device_type: 
 * /camera/realsense2_camera/enable_accel: True
 * /camera/realsense2_camera/enable_color: True
 * /camera/realsense2_camera/enable_confidence: True
 * /camera/realsense2_camera/enable_depth: True
 * /camera/realsense2_camera/enable_fisheye1: False
 * /camera/realsense2_camera/enable_fisheye2: False
 * /camera/realsense2_camera/enable_fisheye: True
 * /camera/realsense2_camera/enable_gyro: True
 * /camera/realsense2_camera/enable_infra1: False
 * /camera/realsense2_camera/enable_infra2: False
 * /camera/realsense2_camera/enable_infra: False
 * /camera/realsense2_camera/enable_pointcloud: False
 * /camera/realsense2_camera/enable_pose: False
 * /camera/realsense2_camera/enable_sync: True
 * /camera/realsense2_camera/filters: 
 * /camera/realsense2_camera/fisheye1_frame_id: camera_fisheye1_f...
 * /camera/realsense2_camera/fisheye1_optical_frame_id: camera_fisheye1_o...
 * /camera/realsense2_camera/fisheye2_frame_id: camera_fisheye2_f...
 * /camera/realsense2_camera/fisheye2_optical_frame_id: camera_fisheye2_o...
 * /camera/realsense2_camera/fisheye_fps: 30
 * /camera/realsense2_camera/fisheye_frame_id: camera_fisheye_frame
 * /camera/realsense2_camera/fisheye_height: 480
 * /camera/realsense2_camera/fisheye_optical_frame_id: camera_fisheye_op...
 * /camera/realsense2_camera/fisheye_width: 640
 * /camera/realsense2_camera/gyro_fps: 400
 * /camera/realsense2_camera/gyro_frame_id: camera_gyro_frame
 * /camera/realsense2_camera/gyro_optical_frame_id: camera_gyro_optic...
 * /camera/realsense2_camera/imu_optical_frame_id: camera_imu_optica...
 * /camera/realsense2_camera/infra1_frame_id: camera_infra1_frame
 * /camera/realsense2_camera/infra1_optical_frame_id: camera_infra1_opt...
 * /camera/realsense2_camera/infra2_frame_id: camera_infra2_frame
 * /camera/realsense2_camera/infra2_optical_frame_id: camera_infra2_opt...
 * /camera/realsense2_camera/infra_fps: 30
 * /camera/realsense2_camera/infra_height: 480
 * /camera/realsense2_camera/infra_rgb: False
 * /camera/realsense2_camera/infra_width: 640
 * /camera/realsense2_camera/initial_reset: False
 * /camera/realsense2_camera/json_file_path: 
 * /camera/realsense2_camera/linear_accel_cov: 0.01
 * /camera/realsense2_camera/odom_frame_id: camera_odom_frame
 * /camera/realsense2_camera/ordered_pc: False
 * /camera/realsense2_camera/pointcloud_texture_index: 0
 * /camera/realsense2_camera/pointcloud_texture_stream: RS2_STREAM_COLOR
 * /camera/realsense2_camera/pose_frame_id: camera_pose_frame
 * /camera/realsense2_camera/pose_optical_frame_id: camera_pose_optic...
 * /camera/realsense2_camera/publish_odom_tf: True
 * /camera/realsense2_camera/publish_tf: True
 * /camera/realsense2_camera/reconnect_timeout: 6.0
 * /camera/realsense2_camera/rosbag_filename: 
 * /camera/realsense2_camera/serial_no: 215222073770
 * /camera/realsense2_camera/stereo_module/exposure/1: 7500
 * /camera/realsense2_camera/stereo_module/exposure/2: 1
 * /camera/realsense2_camera/stereo_module/gain/1: 16
 * /camera/realsense2_camera/stereo_module/gain/2: 16
 * /camera/realsense2_camera/tf_publish_rate: 0.0
 * /camera/realsense2_camera/topic_odom_in: camera/odom_in
 * /camera/realsense2_camera/unite_imu_method: none
 * /camera/realsense2_camera/usb_port_id: 
 * /camera/realsense2_camera/wait_for_device_timeout: -1.0
 * /rosdistro: noetic
 * /rosversion: 1.17.4

NODES
  /camera/
    realsense2_camera (nodelet/nodelet)
    realsense2_camera_manager (nodelet/nodelet)

ROS_MASTER_URI=http://localhost:11311

process[camera/realsense2_camera_manager-1]: started with pid [64]
process[camera/realsense2_camera-2]: started with pid [65]
[INFO] [1762962239.221610782]: Initializing nodelet with 32 worker threads.
[INFO] [1762962239.281496683]: RealSense ROS v2.3.2
[INFO] [1762962239.281514876]: Built with LibRealSense v2.50.0
[INFO] [1762962239.281520043]: Running with LibRealSense v2.50.0
[INFO] [1762962239.300676170]:  
 12/11 15:43:59,304 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 300, error: Resource temporarily unavailable, number: b
[INFO] [1762962239.387564090]: Device with serial number 215222073770 was found.

[INFO] [1762962239.387584243]: Device with physical ID 2-10-13 was found.
[INFO] [1762962239.387588911]: Device with name Intel RealSense D435I was found.
[INFO] [1762962239.387757857]: Device with port number 2-10 was found.
[INFO] [1762962239.387766302]: Device USB type: 3.2
[INFO] [1762962239.388586709]: getParameters...
[INFO] [1762962239.408077818]: setupDevice...
[INFO] [1762962239.408093386]: JSON file is not provided
[INFO] [1762962239.408097454]: ROS Node Namespace: camera
[INFO] [1762962239.408119423]: Device Name: Intel RealSense D435I
[INFO] [1762962239.408124415]: Device Serial No: 215222073770
[INFO] [1762962239.408127960]: Device physical port: 2-10-13
[INFO] [1762962239.408132177]: Device FW version: 05.16.00.01
[INFO] [1762962239.408135826]: Device Product ID: 0x0B3A
[INFO] [1762962239.408143548]: Enable PointCloud: Off
[INFO] [1762962239.408148334]: Align Depth: On
[INFO] [1762962239.408153506]: Sync Mode: On
[INFO] [1762962239.408179355]: Device Sensors: 
[INFO] [1762962239.423480619]: Stereo Module was found.
[INFO] [1762962239.431446806]: RGB Camera was found.
[INFO] [1762962239.431529626]: Motion Module was found.
[INFO] [1762962239.431547176]: (Fisheye, 0) sensor isn't supported by current device! -- Skipping...
[INFO] [1762962239.431553728]: (Confidence, 0) sensor isn't supported by current device! -- Skipping...
[INFO] [1762962239.431727959]: num_filters: 1
[INFO] [1762962239.431735370]: Setting Dynamic reconfig parameters.
hwmon command 0x80( 5 0 0 0 ) failed (response -7= HW not ready)
hwmon command 0x80( 5 0 0 0 ) failed (response -7= HW not ready)
hwmon command 0x80( 5 0 0 0 ) failed (response -7= HW not ready)
hwmon command 0x80( 5 0 0 0 ) failed (response -7= HW not ready)
[INFO] [1762962240.013159254]: Done Setting Dynamic reconfig parameters.
[INFO] [1762962240.013424831]: depth stream is enabled - width: 640, height: 480, fps: 15, Format: Z16
[INFO] [1762962240.013672443]: color stream is enabled - width: 640, height: 480, fps: 15, Format: RGB8
[INFO] [1762962240.014264461]: gyro stream is enabled - fps: 400
[WARN] [1762962240.014274149]: No mathcing profile found for accel with fps=250
[WARN] [1762962240.014280020]: Using default profile instead.
[INFO] [1762962240.014285486]: accel stream is enabled - fps: 100
[INFO] [1762962240.014293561]: setupPublishers...
[INFO] [1762962240.014991553]: Expected frequency for depth = 15.00000
[INFO] [1762962240.016042317]: Expected frequency for color = 15.00000
[INFO] [1762962240.016569349]: Expected frequency for aligned_depth_to_color = 15.00000
[INFO] [1762962240.017922587]: setupStreams...
 12/11 15:44:00,043 WARNING [132068365301504] (ds5-motion.cpp:473) IMU Calibration is not available, default intrinsic and extrinsic will be used.
 12/11 15:44:00,070 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 768, error: Resource temporarily unavailable, number: 11
[INFO] [1762962240.120410706]: SELECTED BASE:Depth, 0
[INFO] [1762962240.125561798]: RealSense Node Is Up!
[WARN] [1762962240.259895208]: 
 12/11 15:44:00,260 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 768, error: Resource temporarily unavailable, number: 11
 12/11 15:44:00,310 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 768, error: Resource temporarily unavailable, number: 11
 12/11 15:44:00,360 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 768, error: Resource temporarily unavailable, number: 11
 12/11 15:44:00,411 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 768, error: Resource temporarily unavailable, number: 11
 12/11 15:44:00,624 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 768, error: Resource temporarily unavailable, number: 11
 12/11 15:44:00,675 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 768, error: Resource temporarily unavailable, number: 11
 12/11 15:44:00,927 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 768, error: Resource temporarily unavailable, number: 11
[WARN] [1762962241.013835667]: Hardware Notification:Motion Module failure,1.76296e+12,Error,Hardware Error

Verifying camera topics are being published...

Bag file will be saved to: /app/rosbags/recording_20251112_154403.bag

Topics to record:
  - /camera/color/image_raw
  - /camera/aligned_depth_to_color/image_raw
  - /camera/color/camera_info
  - /camera/depth/camera_info
  - /camera/imu
  - /camera/accel/sample
  - /camera/gyro/sample


Waiting up to 15s for camera topics to publish messages...
  ✓ /camera/color/image_raw - receiving messages
  ✓ /camera/aligned_depth_to_color/image_raw - receiving messages
  ✓ /camera/color/camera_info - receiving messages

✓ All required camera topics are actively publishing:
  ✓ /camera/color/image_raw
  ✓ /camera/aligned_depth_to_color/image_raw
  ✓ /camera/color/camera_info

>>> Press ENTER to START recording...

>>> Recording in progress. Press Ctrl+C to STOP...

[INFO] [1762962250.583057217]: Subscribing to /camera/accel/sample
[INFO] [1762962250.584340377]: Subscribing to /camera/aligned_depth_to_color/image_raw
[INFO] [1762962250.585177783]: Subscribing to /camera/color/camera_info
[INFO] [1762962250.586000134]: Subscribing to /camera/color/image_raw
[INFO] [1762962250.586814164]: Subscribing to /camera/depth/camera_info
[INFO] [1762962250.587628166]: Subscribing to /camera/gyro/sample
[INFO] [1762962250.588442913]: Subscribing to /camera/imu
[INFO] [1762962250.589416840]: Recording to '/app/rosbags/recording_20251112_154403.bag'.
 12/11 15:44:10,787 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 768, error: Resource temporarily unavailable, number: 11
 12/11 15:44:12,839 WARNING [132068340123392] (messenger-libusb.cpp:42) control_transfer returned error, index: 768, error: Resource temporarily unavailable, number: 11
 12/11 15:44:51,253 ERROR [132067534817024] (ds5-options.cpp:88) Asic Temperature value is not valid!
 12/11 15:44:52,256 ERROR [132067534817024] (ds5-options.cpp:88) Asic Temperature value is not valid!
 12/11 15:44:53,259 ERROR [132067534817024] (ds5-options.cpp:88) Asic Temperature value is not valid!
^C[camera/realsense2_camera-2] killing on exit
[camera/realsense2_camera_manager-1] killing on exit
^Cshutting down processing monitor...
... shutting down processing monitor complete
done

============================================================
Recording Complete!
Bag file: /app/rosbags/recording_20251112_154403.bag
============================================================

Success! Bag saved to: /app/rosbags/recording_20251112_154403.bag

Shutting down camera node...
Done.

Recording session complete!