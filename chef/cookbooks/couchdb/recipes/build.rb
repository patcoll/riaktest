# p node[:os]
# p node[:platform]
# p node[:platform_version]

couch_src = "/usr/local/src/build-couchdb"
couch_service_name = "couchdb"

if node[:platform] == "ubuntu" and node[:platform_version] == "10.04"
  include_recipe "build-essential"
  include_recipe "git"
  include_recipe "zlib"
  package "libssl-dev"
  gem_package "rake"
  git couch_src do
    repository "git://github.com/iriscouch/build-couchdb.git"
    reference "master"
    action :sync
  end

  execute "git submodule update --init" do
    cwd couch_src
  end

  execute "rake" do
    cwd couch_src
    creates "#{couch_src}/build/bin/couchdb"
  end

  template "#{couch_src}/build/etc/couchdb/local.ini" do
    source "local.ini.erb"
    variables({
      "bind_address" => "0.0.0.0"
    })
    notifies :restart, "service[#{couch_service_name}]"
  end

  template "/etc/init/#{couch_service_name}.conf" do
    source "couchdb.build.conf.erb"
    variables({
      "couch_service_name" => couch_service_name,
      "cwd" => couch_src,
      "owner" => "vagrant"
    })
    notifies :restart, "service[#{couch_service_name}]"
  end

  service couch_service_name do
    provider Chef::Provider::Service::Upstart
    restart_command "stop #{couch_service_name}; sleep 1; start #{couch_service_name}"
    supports :status => true, :restart => true
    action [ :enable, :start ]
  end
end
