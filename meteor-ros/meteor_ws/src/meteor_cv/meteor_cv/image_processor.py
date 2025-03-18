#!/usr/bin/env python3

import rclpy
import os
from rclpy.node import Node
from sensor_msgs.msg import CompressedImage
import cv2
from cv_bridge import CvBridge
from ultralytics import YOLO
import subprocess
from geometry_msgs.msg import Twist
import torch
import time
import numpy as np


class ImageProcessor(Node):
    def __init__(self):
        super().__init__('image_processor')
        self.subscription = self.create_subscription(
            CompressedImage,
            'meteorv',
            self.listener_callback,
            10)
        self.subscription  # prevent unused variable warning
        self.bridge = CvBridge()
        self.frame_counter = 3  # frame counter to execute inference model

        # Initialize YOLOv11 model with CUDA or NCNN fallback
        self.model = self.initialize_yolo()

        # Initialize FFmpeg process
        self.ffmpeg_process = self.initialize_ffmpeg()

        # Initialize publisher for cmd_vel
        self.publisher_ = self.create_publisher(Twist, 'cmd_vel', 10)

        # Create a window for displaying the video preview
        cv2.namedWindow('Video Preview', cv2.WINDOW_NORMAL)

    def initialize_yolo(self):
        if torch.cuda.is_available():
            try:
                model = YOLO("yolo11n.pt")
                model.to('cuda')
                self.get_logger().info("PyTorch CUDA Model Loaded")
                return model
            except Exception as e:
                self.get_logger().error(f"Error loading CUDA model: {e}")
                self.get_logger().info("Falling back to NCNN model.")
        try:
            model = YOLO("yolo11n_ncnn_model")
            self.get_logger().info("NCNN Model Loaded")
            return model
        except Exception as e:
            self.get_logger().error(f"Error loading NCNN model: {e}")
            self.get_logger().info("Loading CPU PyTorch model as a last resort.")
            model = YOLO("yolo11n.pt")
            return model

    def initialize_ffmpeg(self):
        ffmpeg_cmd = [
            'ffmpeg',
            '-y',
            '-f', 'rawvideo',
            '-vcodec', 'rawvideo',
            '-pix_fmt', 'bgr24',
            '-s', "{}x{}".format(640, 480),
            '-r', str(30),
            '-i', '-',
            '-vcodec', 'libx264',
            '-pix_fmt', 'yuv420p',
            '-preset', 'ultrafast',
            '-tune', 'zerolatency',
            '-f', 'rtp'
        ]

        rtp_address = os.getenv('RTP_ADDRESS')
        ffmpeg_cmd.append(rtp_address) if rtp_address else ffmpeg_cmd.append('rtp://localhost:5004')

        return subprocess.Popen(ffmpeg_cmd, stdin=subprocess.PIPE)

    def listener_callback(self, msg):
        # self.get_logger().info('Processing video frame')
        np_arr = np.frombuffer(msg.data, np.uint8)
        frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        # frame = self.bridge.imgmsg_to_cv2(msg, 'bgr8')
        # self.get_logger().info(f'Frame size=========>: {frame.shape}')

        if frame is None:
            self.get_logger().error("Failed to decode image")
            return

        # frame_height, frame_width, _ = frame.shape

        if self.frame_counter == 0:
            results = self.model(frame)

            for result in results:
                boxes = result.boxes
                for box in boxes:
                    xyxy = box.xyxy[0].int().cpu().numpy()
                    cls = int(box.cls[0])
                    conf = box.conf[0]

                    if cls == 32 and conf > 0.5:
                        class_name = self.model.names[cls]
                        cv2.rectangle(frame, xyxy[:2], xyxy[2:], (0, 0, 255), 2)
                        cv2.putText(frame, f'{class_name}: {conf:.2f}', (xyxy[0], xyxy[1] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 1)

                        self.steer_car(frame, xyxy)

            self.frame_counter = 3

        self.frame_counter = self.frame_counter - 1

        self.ffmpeg_process.stdin.write(frame.tobytes())

        cv2.imshow('Video Preview', frame)
        cv2.waitKey(1)

    def calculate_center(self, box_coordinates):
        x_min, y_min, x_max, y_max = box_coordinates
        center_x = (x_min + x_max) / 2
        center_y = (y_min + y_max) / 2
        return center_x, center_y

    def steer_car(self, frame, box_coordinates):
        frame_center_x = frame.shape[1] / 2
        frame_center_y = frame.shape[0] / 2
        center_x, center_y = self.calculate_center(box_coordinates)
        offset_x = center_x - frame_center_x
        offset_y = center_y - frame_center_y

        move_forward = Twist()
        move_forward.linear.x = 0.2
        move_forward.linear.z = 0.2

        turn_left = Twist()
        turn_left.linear.x = 0.3
        turn_left.linear.z = -0.3

        turn_right = Twist()
        turn_right.linear.x = -0.3
        turn_right.linear.z = 0.3

        if offset_x > 20:
            self.publisher_.publish(turn_right)
            self.get_logger().info("Turn right")
        elif offset_x < -20:
            self.publisher_.publish(turn_left)
            self.get_logger().info("Turn left")
        else:
            self.publisher_.publish(move_forward)
            self.get_logger().info("Move forward")

def main(args=None):
    rclpy.init(args=args)
    node = ImageProcessor()
    rclpy.spin(node)
    node.destroy_node()
    cv2.destroyAllWindows()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
