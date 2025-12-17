FROM osrf/ros:noetic-desktop-full

############################## SYSTEM PARAMETERS ##############################
## Base arguments
ARG USER=initial
ARG GROUP=initial
ARG UID=1000
ARG GID=${UID}
ARG SHELL=/bin/bash

## NVIDIA GraphicsCard parameter
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
# ENV NVIDIA_DRIVER_CAPABILITIES graphics, utility, compute

## Setup users and groups
RUN groupadd --gid ${GID} ${GROUP} \
  && useradd --gid ${GID} --uid ${UID} -ms ${SHELL} ${USER} \
  && mkdir -p /etc/sudoers.d \
  && echo "${USER}:x:${UID}:${UID}:${USER},,,:$HOME:${shell}" >> /etc/passwd \
  && echo "${USER}:x:${UID}:" >> /etc/group \
  && echo "${USER} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USER}" \
  && chmod 0440 "/etc/sudoers.d/${USER}"

## Replace apt urls
# Taiwan
# RUN sed -i 's@archive.ubuntu.com@tw.archive.ubuntu.com@g' /etc/apt/sources.list
# TKU
RUN sed -i 's@archive.ubuntu.com@ftp.tku.edu.tw/@g' /etc/apt/sources.list

############################### INSTALL & SETUP ###############################
## Install packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  sudo htop git wget curl \
  # Shell
  byobu zsh \
  terminator \
  dbus-x11 libglvnd0 libgl1 libglx0 libegl1 libxext6 libx11-6 \
  # Editing tools
  nano vim gedit\
  gnome-terminal libcanberra-gtk-module libcanberra-gtk3-module \
  # Work tools
  python3-pip python3-dev python3-setuptools python3-catkin-tools\
  # install matplot
  python3-tk \
  # install udev for reload rules
  udev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  && update-ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists

# install limx simulator library
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-urdf \
    ros-noetic-kdl-parser \
    ros-noetic-urdf-parser-plugin \
    ros-noetic-hardware-interface \
    ros-noetic-controller-manager \
    ros-noetic-controller-interface \
    ros-noetic-robot-state-* \
    ros-noetic-joint-state-* \
    ros-noetic-controller-manager-msgs \
    ros-noetic-control-msgs \
    ros-noetic-ros-control \
    ros-noetic-gazebo-* \
    ros-noetic-rqt-gui \
    ros-noetic-rqt-controller-manager \
    ros-noetic-plotjuggler* \
    ros-noetic-joy-teleop ros-noetic-joy \
    cmake build-essential libpcl-dev libeigen3-dev \
    libopencv-dev libmatio-dev \
    libboost-all-dev libtbb-dev liburdfdom-dev liborocos-kdl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists

WORKDIR /home/${USER}/.tmp

## setup custom configuration
COPY config .

## ROS Arguments
# Is the computer master or slave in ROS
ARG ROS_TYPE=MASTER

# ARG ROS_MASTER_IP=163.13.164.148
ARG ROS_MASTER_IP=localhost
ARG ROS_SLAVE_IP=localhost

## Favorite shell when using byobu
ARG BYOBU_SHELL=zsh

## Set User configuration
RUN bash ./pip/pip_setup.sh \
    && rm -rf /home/${USER}/.tmp

## Copy entrypoint
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh

WORKDIR /home/${USER}

## Set terminator font size
RUN mkdir -p /home/${USER}/.config/terminator && \
    cat << 'EOF' > /home/${USER}/.config/terminator/config
[global_config]
[keybindings]
[profiles]
  [[default]]
    cursor_color = "#aaaaaa"
    font = Monospace 16
    use_system_font = False
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
EOF

## Switch user to ${USER}
USER ${USER}

RUN sudo mkdir work

## Make SSH available
EXPOSE 22

## Switch to user's HOME folder
WORKDIR /home/${USER}/work
RUN echo "source ~/work/devel/setup.bash"  >> ~/.bashrc

ENTRYPOINT ["/entrypoint.sh", "terminator"]
