#include <cstdio>
#include <iostream>
#include <sstream>
#include <libserial/SerialPort.h>
#include <jsoncpp/json/json.h>

#include "rclcpp/rclcpp.hpp"
#include <geometry_msgs/msg/twist.hpp>

class MotionController : public rclcpp::Node
{
public:
    MotionController() : Node("motion_controller")
    {
        RCLCPP_INFO(this->get_logger(), "Initializing MotionController...");
        open_serial_port();

        // Subscribe to cmd_vel topic for motion-related messages
        cmd_vel_subscriber_ = this->create_subscription<geometry_msgs::msg::Twist>(
            "cmd_vel", 1, std::bind(&MotionController::motion_callback, this, std::placeholders::_1));

    }

private:
    void open_serial_port()
    {
        try
        {
            my_serial.Open("/dev/ttyS0");
            my_serial.SetBaudRate(LibSerial::BaudRate::BAUD_115200);
            RCLCPP_INFO(this->get_logger(), "Serial port opened successfully.");
        }
        catch (const LibSerial::OpenFailed &e)
        {
            RCLCPP_ERROR(this->get_logger(), "Failed to open serial port: %s", e.what());
        }
    }

    void motion_callback(const geometry_msgs::msg::Twist::SharedPtr msg)
    {
        try
        {
            if (!my_serial.IsOpen())
            {
                RCLCPP_ERROR(this->get_logger(), "Serial port is not open!");
                return;
            }

            // Build and send motion command
            std::string motion_command = build_motion_json(msg);
            my_serial.Write(motion_command + "\n");

            // Trigger IMU command explicitly for clarity
            send_imu_request();
        }
        catch (const std::exception &e)
        {
            RCLCPP_ERROR(this->get_logger(), "Error in motion_callback: %s", e.what());
        }
    }

    void send_imu_request()
    {
        try
        {
            if (!my_serial.IsOpen())
            {
                RCLCPP_ERROR(this->get_logger(), "Serial port is not open!");
                return;
            }

            // Build and send IMU request
            std::string imu_command = build_imu_json();
            my_serial.Write(imu_command + "\n");

            // Wait for and read the IMU response
            std::string response;
            my_serial.ReadLine(response, '\n', 5000); // Adjust timeout if necessary
            process_json_response(response);
        }
        catch (const std::exception &e)
        {
            RCLCPP_ERROR(this->get_logger(), "Error requesting IMU data: %s", e.what());
        }
    }

    std::string build_motion_json(const geometry_msgs::msg::Twist::SharedPtr msg)
    {
        double L = msg->linear.x;
        double R = msg->linear.z;

        std::ostringstream oss;
        oss << "{\"T\":1,\"L\":" << L << ",\"R\":" << R << "}";
        return oss.str();
    }

    std::string build_imu_json()
    {
        return "{\"T\":126}";
    }

    void process_json_response(const std::string &response)
    {
        try
        {
            Json::Value root;
            Json::CharReaderBuilder reader;
            std::string errors;

            std::istringstream stream(response);
            if (!Json::parseFromStream(reader, stream, &root, &errors))
            {
                RCLCPP_ERROR(this->get_logger(), "Failed to parse JSON: %s", errors.c_str());
                return;
            }

            // Log all key-value pairs
            for (const auto &key : root.getMemberNames())
            {
                RCLCPP_INFO(this->get_logger(), "%s: %s", key.c_str(), root[key].toStyledString().c_str());
            }
        }
        catch (const std::exception &e)
        {
            RCLCPP_ERROR(this->get_logger(), "Error processing JSON response: %s", e.what());
        }
    }

    rclcpp::Subscription<geometry_msgs::msg::Twist>::SharedPtr cmd_vel_subscriber_;
    LibSerial::SerialPort my_serial;
};

int main(int argc, char **argv)
{
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<MotionController>());
    rclcpp::shutdown();
    return 0;
}
