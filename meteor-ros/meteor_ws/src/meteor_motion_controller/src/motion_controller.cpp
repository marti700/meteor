#include <cstdio>
#include <iostream>
#include <libserial/SerialPort.h>
#include <jsoncpp/json/json.h>

#include "rclcpp/rclcpp.hpp"
#include <geometry_msgs/msg/twist.hpp>

class MotionController : public rclcpp::Node
{

public:
  MotionController() : Node("motion_controller")
  {
    open_serial_port();

    subscriber_ = this->create_subscription<geometry_msgs::msg::Twist>(
        "cmd_vel", 1, std::bind(&MotionController::motion_callback, this, std::placeholders::_1));
  }

private:
  void open_serial_port()
  {
    try
    {
      // Configure the serial port
      my_serial.Open("/dev/ttyS0");
      my_serial.SetBaudRate(LibSerial::BaudRate::BAUD_115200);
    }
    catch (const LibSerial::OpenFailed &e)
    {
      std::cerr << "Failed to open serial port: " << e.what() << std::endl;
    }
  }

  void motion_callback(const geometry_msgs::msg::Twist::SharedPtr msg)
  {
    // RCLCPP_INFO(this->get_logger(), "Received cmd_vel message: linear.x=%.2f, angular.z=%.2f", msg->linear.x, msg->angular.z);

    try
    {

      if (!my_serial.IsOpen())
      {
        std::cerr << "Failed to open serial port!" << std::endl;
      }
      std::string command = build_json(msg);
      // std::cout << command << std::endl;
      my_serial.Write(command + "\n");
    }

    catch (const LibSerial::OpenFailed &e)
    {
      std::cerr << "Failed to open serial port: " << e.what() << std::endl;
    }
    catch (const std::exception &e)
    {
      std::cerr << "Error: " << e.what() << std::endl;
      my_serial.Close();
    }
  }

  std::string build_json(const geometry_msgs::msg::Twist::SharedPtr msg)
  {
    // Rotate axis by 45 degrees
    double L = (0.707107 * msg->linear.x) + (-0.707107 * msg->angular.z);
    double R = (0.707107 * msg->linear.x) + (0.707107 * msg->angular.z);

    if (msg->linear.x < 0 && (std::abs(L) != std::abs(R)))
    {
      std::swap(L, R);
    }

    // Ensure values stay within rover limits
    L = std::clamp(L, -0.5, 0.5);
    R = std::clamp(R, -0.5, 0.5);

    std::ostringstream oss;
    // std::cout << msg->linear.x << " " << msg->linear.z << std::endl;
    oss << "{\"T\":1,\"L\":" << L << ",\"R\":" << R << "}";
    // std::cout << oss.str() << std::endl;
    return oss.str();
  }
  rclcpp::Subscription<geometry_msgs::msg::Twist>::SharedPtr subscriber_;
  LibSerial::SerialPort my_serial;
};

int main(int argc, char **argv)
{
  rclcpp::init(argc, argv);
  // auto node = std::make_shared<rclcpp::Node>("mctrl_telop");
  rclcpp::spin(std::make_shared<MotionController>());
  rclcpp::shutdown();
  return 0;
}
