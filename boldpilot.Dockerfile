ARG BASE_IMAGE=docker.io/ardasevinc/boldpilot:noetic-l4t-r32.4.3
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-c"] 
ENV SHELL /bin/bash

ENV DEBIAN_FRONTEND=noninteractive
ARG MAKEFLAGS=-j$(nproc)
ENV LANG=en_US.UTF-8 
ENV PYTHONIOENCODING=utf-8
RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

ENV ROS_DISTRO=noetic
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}

WORKDIR /tmp

RUN mkdir ros_pkg_ws && \
    cd ros_pkg_ws && \
    mkdir src && \
    source /opt/ros/noetic/setup.bash && \
    rosinstall_generator joy zed-ros-wrapper --rosdistro ${ROS_DISTRO} --deps --tar --exclude RPP > boldpilot.rosinstall && \
    vcs import --input boldpilot.rosinstall ./src && \
    apt-get update && \
    rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro ${ROS_DISTRO} -y && \
    catkin_make_isolated --merge --install --install-space /opt/ros/noetic -DCMAKE_BUILD_TYPE=Release && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    rm -rf ${ROS_ROOT}/src && \
    rm -rf ${ROS_ROOT}/logs && \
    rm -rf ${ROS_ROOT}/build