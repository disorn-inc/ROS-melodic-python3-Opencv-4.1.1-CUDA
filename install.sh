#!/bin/bash
'''
BSD 3-Clause License

Copyright (c) 2020, rootadminWalker
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'''

echo '[WARN] This version of ROS is compatible with ubuntu 18.04 (Bionic) or 17.04 (Artful) and Debian Strench'
echo '[LIST] Things going to install:'
echo '1, pip'
echo '2, Opencv 4.1.1 CUDA Version'
echo '3, ROS melodic with python3'
echo '[INFO] You have to install CUDA>=10.0 and nvidia drivers before this operation'
echo '[INFO] You will be granted to enter your password at the beginning for permission'
echo '[INFO] The system will grant you to enter your password again when the installation started more than 5 minutes'
echo '[INFO] Press ENTER IF YOU PROCESSED TO START THE INSTALLATION'
echo '[INFO] Press CTRL+C to CANCEL'
read

ROS_PATH=$PWD

echo '[INFO] Updating and upgrading packages'
sudo apt update -y
sudo apt upgrade -y

echo '[PROGRESS 1/3] pip'
echo '[INFO] Installing pip'
echo
sudo apt install python3-pip -y
sudo -H pip3 install --upgrade pip

echo '[INFO] Installing Opencv CUDA 4.1.1'
echo '[INFO] Removing Installed versions'
echo
sudo apt purge '*libopencv*' -y
sudo apt autoremove -y

echo '[INFO] Installing requirements'
sudo apt update
sudo apt install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt install -y python2.7-dev python3.6-dev python-dev python-numpy python3-numpy
sudo apt install -y libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
sudo apt install -y libv4l-dev v4l-utils qv4l2 v4l2ucp
sudo apt install -y curl
sudo apt update -y

echo '[PROGRESS 2/3] Opencv 4.1.1 CUDA Version'
echo '[INFO] Downloading Opencv 4.1.1'
echo
cd ~
curl -L https://github.com/opencv/opencv/archive/4.1.1.zip -o opencv-4.1.1.zip
curl -L https://github.com/opencv/opencv_contrib/archive/4.1.1.zip -o opencv_contrib-4.1.1.zip
unzip opencv-4.1.1.zip
unzip opencv_contrib-4.1.1.zip
cd opencv-4.1.1/
sed -i 's/include <Eigen\/Core>/include <eigen3\/Eigen\/Core>/g' modules/core/include/opencv2/core/private.hpp

echo '[INFO] Building Opencv 4.1.1'
echo
mkdir build
cd build/
cmake -D WITH_CUDA=ON -D CUDA_ARCH_BIN="5.3,6.2,7.2,7.5" -D CUDA_ARCH_PTX="7.5" -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.1.1/modules -D WITH_GSTREAMER=ON -D WITH_LIBV4L=ON -D BUILD_opencv_python2=ON -D BUILD_opencv_python3=ON -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
make -j$(nproc)

echo '[INFO] Installing Opencv 4.1.1'
echo
sudo make install

echo '[PROGRESS 3/3] ROS melodic with python3'
echo '[INFO] Setting up keys'
echo

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt update -y
sudo apt install -y python3 python3-dev python3-pip build-essential -y

echo '[INFO] Installing packages which build ROS'
echo

sudo -H pip3 install rosdep rospkg rosinstall_generator rosinstall wstool vcstools catkin_tools catkin_pkg

echo '[INFO] Initializing packages'
echo

sudo rosdep init
rosdep update

echo '[INFO] Prepare for installation'
echo

catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so
catkin config --init -DCMAKE_BUILD_TYPE=Release --blacklist rqt_rviz rviz_plugin_tutorials librviz_tutorial --install

echo '[INFO] Installing ROS melodic with python3'
echo

cd $ROS_PATH
cd melodic
rosdep install --from-path src --ignore-src --rosdistro melodic -y

export ROS_PYTHON_VERSION=3
sudo ./src/catkin/bin/catkin_make_isolated --install --install-space /opt/ros/melodic -DCMAKE_BUILD_TYPE=Release

sudo apt install ros-melodic-gazebo* -y

echo 'source /opt/ros/melodic/setup.bash' >> ~/.bashrc
source ~/.bashrc

echo '[INFO] Making catkin workspace'
echo

mkdir ~/catkin_ws/src
cd ~/catkin_ws
catkin_make
cd ~
echo 'source ~/catkin_ws/devel/setup.bash' >> ~/.bashrc
source ~/.bashrc

echo '[DONE] The installation has completed! Start your journey now!'

