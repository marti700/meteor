#include <cstdio>
#include "rclcpp/rclcpp.hpp"
#include <geometry_msgs/msg/twist.hpp>


class MctrlTeleop : public rclcpp::Node
{
  public:
    MctrlTeleop() : Node ("mctrl_teleop")
    {
      subscriber_ = this->create_subscription<geometry_msgs::msg::Twist>(
        "cmd_vel", 3, std::bind(&MctrlTeleop::teleop_callback, this, std::placeholders::_1)
      );
    }

  private:
    void teleop_callback(const geometry_msgs::msg::Twist::SharedPtr msg)
    {
      RCLCPP_INFO(this->get_logger(), "Received cmd_vel message: linear.x=%.2f, angular.z=%.2f", msg->linear.x, msg->angular.z);
    }

   rclcpp::Subscription<geometry_msgs::msg::Twist>::SharedPtr subscriber_;
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);
  // auto node = std::make_shared<rclcpp::Node>("mctrl_telop");
  rclcpp::spin(std::make_shared<MctrlTeleop>());
  rclcpp::shutdown();
  return 0;
}