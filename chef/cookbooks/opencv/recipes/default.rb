#
# Cookbook Name:: opencv
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# by default should install opencv with python support

# dependencies
include_recipe "build-essential"
include_recipe "python"
include_recipe "zlib"
python_pip "numpy" do
  action :install
end
package "cmake"
# package "libjpeg62"
# package "libjpeg62-dev"
# package "libpng12-0"
# package "libpng12-0-dev"

remote_file "/usr/local/src/OpenCV-2.4.0.tar.bz2" do
  source "http://downloads.sourceforge.net/project/opencvlibrary/opencv-unix/2.4.0/OpenCV-2.4.0.tar.bz2"
  checksum "3b5fedb2fc6"
  not_if { File.exists?("/usr/local/lib/libopencv_core.so") }
end

bash "install-opencv-2.4.0" do
  creates "/usr/local/lib/libopencv_core.so"
  cwd "/usr/local/src"
  code <<-SH
    tar xjf OpenCV-2.4.0.tar.bz2
    cd OpenCV-2.4.0
    mkdir release
    cd release
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D BUILD_PYTHON_SUPPORT=ON ..
    make install
  SH
end
