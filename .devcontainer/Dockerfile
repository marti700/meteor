# take the image i build in step one and usit as base image
FROM marti700/ros_humble:1.0.0

# make bash the default shell, docker normally uses sh and we will have trouble later if this is not done
SHELL ["/bin/bash", "-c"]

# you can delte this installs, these were the tools i use to build
# meteor-asm (see https://github.com/marti700/meteor/tree/master/meteor-asm)
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install \
     build-essential \
     gcc-arm-none-eabi \
     binutils-multiarch \
     gdb-multiarch \
  && rm -rf /var/lib/apt/lists/*

# to use the ros2 command one have to source a setup.bash file located at /opt/ros/humble/
# it is annoying to do that each time a terminal is open so i just add it to the the container .bashrc file
RUN source /opt/ros/humble/setup.bash \
  && export ROS_DISTRO=humble \
  && echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# these commands sets the development workspace
RUN mkdir /workspaces

WORKDIR /workspaces