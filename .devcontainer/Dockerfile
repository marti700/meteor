FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install \
    build-essential \
    gcc-arm-none-eabi \
    binutils-multiarch \
    gdb-multiarch \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get -y install software-properties-common \
    && add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install ros-humble-desktop



RUN mkdir /workspaces

WORKDIR /workspaces