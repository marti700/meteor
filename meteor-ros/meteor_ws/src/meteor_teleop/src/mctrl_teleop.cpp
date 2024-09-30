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
        "cmd_vel", 3, std::bind(&MctrlTeleop::teleop_callback, this, std::placeholders::_1));
  }

private:
  void teleop_callback(const geometry_msgs::msg::Twist::SharedPtr msg)
  {
    RCLCPP_INFO(this->get_logger(), "Received cmd_vel message: linear.x=%.2f, angular.z=%.2f", msg->linear.x, msg->angular.z);

    LibSerial::SerialPort my_serial;

    try
    {
      // Configure the serial port
      my_serial.Open("/dev/ttyS0");
      my_serial.SetBaudRate(LibSerial::BaudRate::BAUD_115200);

      if (!my_serial.IsOpen())
      {
        std::cerr << "Failed to open serial port!" << std::endl;
      }

      std::string command = build_json(msg);
      std::cout << command << std::endl;
      my_serial.Write(command + "\n");
      // Main loop to send commands
      // while (true)
      // {
      //   my_serial.Write(command + "\n");
      //   std::cout << "Sent: " << command << std::endl;
      //   // std::this_thread::sleep_for(std::chrono::seconds(1));  // Adjust the delay as needed
      // }
    }
    catch (const LibSerial::OpenFailed &e)
    {
      std::cerr << "Failed to open serial port: " << e.what() << std::endl;
    }
    catch (const std::exception &e)
    {
      std::cerr << "Error: " << e.what() << std::endl;
    }
  }

  std::string build_json(const geometry_msgs::msg::Twist::SharedPtr msg)
  {
    std::ostringstream oss;
    std::cout << msg->linear.x << " " << msg->linear.z << std::endl;
    oss << "{\"T\":1,\"L\":" << msg->angular.z << ",\"R\":" << msg->angular.z << "}";
    std::cout << oss.str() << std::endl;
    return oss.str();
  }

  rclcpp::Subscription<geometry_msgs::msg::Twist>::SharedPtr subscriber_;
};

int main(int argc, char **argv)
{
  rclcpp::init(argc, argv);
  // auto node = std::make_shared<rclcpp::Node>("mctrl_telop");
  rclcpp::spin(std::make_shared<MctrlTeleop>());
  rclcpp::shutdown();
  return 0;
}