#
# Cookbook Name:: date
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "ntpdate"

bash "update_timezone_settings" do
  user "root"
  environment "TZ" => "America/New_York"
  code <<-SH
    echo 'America/New_York' > /etc/timezone
    dpkg-reconfigure --frontend noninteractive tzdata
    ntpdate pool.ntp.org
  SH
  not_if { File.read("/etc/timezone") =~ /America\/New_York/ }
end

cron "ntpdate" do
  user "root"
  minute "0"
  command "ntpdate pool.ntp.org"
end
