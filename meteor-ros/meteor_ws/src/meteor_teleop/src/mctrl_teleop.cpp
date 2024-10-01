#include <cstdio>
#include <iostream>
#include <libserial/SerialPort.h>
#include <jsoncpp/json/json.h>

#include "rclcpp/rclcpp.hpp"
#include <geometry_msgs/msg/twist.hpp>

class MctrlTeleop : public rclcpp::Node
{
public:
  MctrlTeleop() : Node("mctrl_teleop")
  {
    subscriber_ = this->create_subscription<geometry_msgs::msg::Twist>(
        "cmd_vel", 0, std::bind(&MctrlTeleop::teleop_callback, this, std::placeholders::_1));

    try
    {
      // Open the serial port once during initialization
      my_serial.Open("/dev/ttyS0");
      my_serial.SetBaudRate(LibSerial::BaudRate::BAUD_115200);

      if (!my_serial.IsOpen())
      {
        throw std::runtime_error("Failed to open serial port!");
      }
    }
    catch (const LibSerial::OpenFailed &e)
    {
      RCLCPP_ERROR(this->get_logger(), "Failed to open serial port: %s", e.what());
    }
    catch (const std::exception &e)
    {
      RCLCPP_ERROR(this->get_logger(), "Error: %s", e.what());
    }
  }

  ~MctrlTeleop()
  {
    // Close the serial port when the node is destroyed
    if (my_serial.IsOpen())
    {
      my_serial.Close();
    }
  }

private:
  void teleop_callback(const geometry_msgs::msg::Twist::SharedPtr msg)
  {
    RCLCPP_INFO(this->get_logger(), "Received cmd_vel message: linear.x=%.2f, angular.z=%.2f", msg->linear.x, msg->angular.z);

    try
    {
      std::string command = build_json(msg);
      RCLCPP_INFO(this->get_logger(), "Sending command: %s", command.c_str());
      my_serial.Write(command + "\n");
    }
    catch (const std::exception &e)
    {
      RCLCPP_ERROR(this->get_logger(), "Error: %s", e.what());
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
    oss << "{\"T\":1,\"L\":" << L << ",\"R\":" << R << "}";
    return oss.str();
  }

  rclcpp::Subscription<geometry_msgs::msg::Twist>::SharedPtr subscriber_;
  LibSerial::SerialPort my_serial;
};

int main(int argc, char **argv)
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<MctrlTeleop>());
  rclcpp::shutdown();
  return 0;
}
