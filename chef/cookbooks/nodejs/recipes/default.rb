#
# Cookbook Name:: nodejs
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "build-essential"
include_recipe "python"
package "libssl-dev"

remote_file "/usr/local/src/node-#{node[:nodejs][:version]}.tar.gz" do
  source "http://nodejs.org/dist/#{node[:nodejs][:version]}/node-#{node[:nodejs][:version]}.tar.gz"
  checksum "fdd61c47"
  not_if { File.exists?("#{node[:nodejs][:install_prefix]}/bin/node") }
end

bash "install-nodejs-#{node[:nodejs][:version]}" do
  creates "#{node[:nodejs][:install_prefix]}/bin/node"
  cwd "/usr/local/src"
  code <<-SH
    export JOBS=2
    tar xfz node-#{node[:nodejs][:version]}.tar.gz
    cd node-#{node[:nodejs][:version]}
    ./configure --prefix=#{node[:nodejs][:install_prefix]}
    make install
  SH
end

remote_file "/usr/local/src/npm-#{node[:npm][:version]}.tgz" do
  source "http://nodejs.org/dist/#{node[:nodejs][:version]}/npm-#{node[:npm][:version]}.tgz"
  checksum "73c29dc1"
end

bash "install-npm-#{node[:npm][:version]}" do
  creates "#{node[:npm][:install_prefix]}/bin/npm"
  cwd "/usr/local/src"
  code <<-SH
    tar xfz npm-#{node[:npm][:version]}.tgz
    cd npm
    ./configure --prefix=#{node[:npm][:install_prefix]}
    make install
  SH
end

