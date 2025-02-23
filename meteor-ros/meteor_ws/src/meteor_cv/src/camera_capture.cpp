#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/image.hpp"
#include <opencv2/opencv.hpp>

class CameraCapture : public rclcpp::Node
{
public:
  CameraCapture() : Node("camera_capture"), cap_(0)
  {
    if (!cap_.isOpened())
    {
      RCLCPP_ERROR(this->get_logger(), "Failed to open /dev/video0");
      rclcpp::shutdown();
    }
    publisher_ = this->create_publisher<sensor_msgs::msg::Image>("meteorv", 10);
    timer_ = this->create_wall_timer(
        std::chrono::milliseconds(33),
        std::bind(&CameraCapture::publish_frame, this));
  }

private:
  void publish_frame()
  {
    cv::Mat frame;
    cap_ >> frame;
    if (frame.empty())
    {
      RCLCPP_WARN(this->get_logger(), "Captured empty frame");
      return;
    }

    RCLCPP_INFO(this->get_logger(), "Captured and publishing frame");
    sensor_msgs::msg::Image msg;
    msg.header.stamp = this->get_clock()->now();
    msg.height = frame.rows;
    msg.width = frame.cols;
    msg.encoding = "bgr8";
    msg.is_bigendian = false;
    msg.step = static_cast<sensor_msgs::msg::Image::_step_type>(frame.step);
    msg.data.assign(frame.datastart, frame.dataend);
    RCLCPP_INFO(this->get_logger(), "Image height: %d, width: %d", msg.height, msg.width);
    RCLCPP_INFO(this->get_logger(), "Image data size: %ld", msg.data.size());
    publisher_->publish(msg);
  }

  rclcpp::Publisher<sensor_msgs::msg::Image>::SharedPtr publisher_;
  rclcpp::TimerBase::SharedPtr timer_;
  cv::VideoCapture cap_;
};

int main(int argc, char *argv[])
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<CameraCapture>());
  rclcpp::shutdown();
  return 0;
}
