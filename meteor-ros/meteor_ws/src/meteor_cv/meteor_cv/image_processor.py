#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image
import cv2
from cv_bridge import CvBridge
from ultralytics import YOLO
import serial
import subprocess

class ImageProcessor(Node):
    def __init__(self):
        super().__init__('image_processor')
        self.subscription = self.create_subscription(
            Image,
            'meteorv',
            self.listener_callback,
            10)
        self.subscription  # prevent unused variable warning
        self.bridge = CvBridge()

        # Initialize YOLOv11 model
        self.model = self.initialize_yolo()

        # Initialize serial communication
        # self.ser = serial.Serial('/dev/ttyS0', baudrate=115200, dsrdtr=None)
        # self.ser.setRTS(False)
        # self.ser.setDTR(False)

        # Initialize FFmpeg process
        self.ffmpeg_process = self.initialize_ffmpeg()

    def initialize_yolo(self):
        try:
            model = YOLO("yolo11n_ncnn_model")  # Try to load the NCNN model first
            self.get_logger().info("NCNN Model Loaded")
        except:
            model = YOLO("yolo11n.pt")  # Load the PyTorch model
            self.get_logger().info("PyTorch Model Loaded")
            self.get_logger().info("Exporting to NCNN...")
            model.export(format="ncnn")  # Export to NCNN format
            model = YOLO("yolo11n_ncnn_model")  # Load the NCNN model
            self.get_logger().info("NCNN Model Loaded")
        return model

    def initialize_ffmpeg(self):
        ffmpeg_cmd = [
            'ffmpeg',
            '-y',  # Overwrite output files without asking
            '-f', 'rawvideo',  # Input format is raw video
            '-vcodec', 'rawvideo',  # Input video codec is raw video
            '-pix_fmt', 'bgr24',  # Pixel format is BGR24 (OpenCV format)
            # '-s', "{}x{}".format(640, 480),  # Set frame size
            '-s', "640x480",
            '-r', str(20),  # Set frame rate
            '-i', '-',  # Input comes from a pipe
            '-vcodec', 'libx264',  # Output video codec is libx264 (H.264 encoding)
            '-pix_fmt', 'yuv420p',  # Pixel format for the encoded video
            '-preset', 'ultrafast',  # Encoding preset (faster encoding, lower quality)
            '-tune', 'zerolatency',  # Tune for zero latency streaming
            '-f', 'rtp',  # Output format is RTP (Real-time Transport Protocol)
        ]

        # Read RTP address from environment variable
        rtp_address = os.getenv('RTP_ADDRESS')
        ffmpeg_cmd.append(rtp_address) if rtp_address else ffmpeg_cmd.append('rtp://localhost:5004')

        return subprocess.Popen(ffmpeg_cmd, stdin=subprocess.PIPE)

    def listener_callback(self, msg):
        self.get_logger().info('Processing video frame')
        frame = self.bridge.imgmsg_to_cv2(msg, 'bgr8')

        # Perform object detection with YOLOv11 (NCNN or PyTorch)
        results = self.model(frame)  # Run inference

        # Process the results
        for result in results:
            boxes = result.boxes
            for box in boxes:
                xyxy = box.xyxy[0].int().cpu().numpy()  # Bounding box coordinates (x1, y1, x2, y2)
                cls = int(box.cls[0])  # Class ID
                conf = box.conf[0]  # Confidence score

                # If the detected object is a "sports ball" and the confidence is above 50%
                if cls == 32 and conf > 0.5:  # Sports ball class (class ID might be different, double check)
                    class_name = self.model.names[cls]  # Get class name
                    cv2.rectangle(frame, xyxy[:2], xyxy[2:], (0, 0, 255), 2)  # Draw red rectangle
                    cv2.putText(frame, f'{class_name}: {conf:.2f}', (xyxy[0], xyxy[1] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 1)  # Add text label

                    # self.steer_car(frame, xyxy)  # Call steer to object location

        # Write the processed frame to FFmpeg for streaming
        self.ffmpeg_process.stdin.write(frame.tobytes())

    def calculate_center(self, box_coordinates):
        x_min, y_min, x_max, y_max = box_coordinates
        center_x = (x_min + x_max) / 2
        center_y = (y_min + y_max) / 2
        return center_x, center_y

    # def steer_car(self, frame, box_coordinates):
    #     frame_center_x = frame.shape[1] / 2
    #     frame_center_y = frame.shape[0] / 2
    #     center_x, center_y = self.calculate_center(box_coordinates)
    #     offset_x = center_x - frame_center_x
    #     offset_y = center_y - frame_center_y

    #     move_forward = '{"T":1,"L":0.2,"R":0.2}\n'
    #     turn_left = '{"T":1,"L":-0.2,"R":0.2}\n'
    #     turn_right = '{"T":1,"L":0.2,"R":-0.2}\n'

    #     if offset_x > 20:
    #         self.ser.write(turn_right.encode())
    #         self.get_logger().info("Turn right")
    #     elif offset_x < -20:
    #         self.ser.write(turn_left.encode())
    #         self.get_logger().info("Turn left")
    #     else:
    #         self.ser.write(move_forward.encode())
    #         self.get_logger().info("Move forward")

def main(args=None):
    rclpy.init(args=args)
    node = ImageProcessor()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
