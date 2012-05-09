#
# Cookbook Name:: riaktest
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "erlang"
package "erlang-reltool"

# need git for source install because it grabs deps with it
include_recipe "git"
include_recipe "riak"
