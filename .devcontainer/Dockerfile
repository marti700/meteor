# Use the image built in step one as the base image
FROM marti700/ros_humble:1.0.0

# Make bash the default shell
SHELL ["/bin/bash", "-c"]

# Create a non-root user and group with a home directory using adduser
# RUN adduser --disabled-password --gecos "" vscode

# Install necessary packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install \
     build-essential \
     gcc-arm-none-eabi \
     binutils-multiarch \
     ros-humble-joy-linux \
     ros-humble-teleop-twist-joy \
     libjsoncpp-dev \
     libserial-dev \

  && rm -rf /var/lib/apt/lists/*

# Source the ROS 2 setup file and update .bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# Set up the development workspace
# RUN mkdir /workspaces && chown vscode:vscode /workspaces

# Switch to the non-root user
# USER vscode

# Set the working directory
WORKDIR /workspaces
