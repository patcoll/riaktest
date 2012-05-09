define :mongo_server, :enable => true, :port => 27017 do
  if node[:platform] == 'ubuntu'
    package "python-software-properties"

    bash "import-gpg-key" do
      code "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
      not_if { File.read("/etc/apt/sources.list") =~ /10gen/ }
    end

    bash "append-10gen-repo" do
      if node[:platform_version].to_f >= 10.04
        code %[echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list]
      else
        code %[echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-sysvinit dist 10gen" | tee -a /etc/apt/sources.list]
      end
      notifies :run, resources(:execute => "apt-get update"), :immediately
      not_if { File.read("/etc/apt/sources.list") =~ /10gen/ }
    end

    # make sure any lingering mongodb ubuntu pkg is removed
    package "mongodb-10gen" do
      action :remove
    end
  end

  # include_recipe "build-essential"
  # include_recipe "boost"
  name = params[:name]
  port = params[:port]
  src = node[:build_essential][:src_dir]
  prefix = node[:mongodb][:prefix]
  
  if params[:enable]
    case node[:kernel][:machine]
    when "x86_64"
      remote_file "#{src}/mongodb-linux-x86_64-2.0.4.tgz" do
        source "http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.4.tgz"
        not_if { File.exists?("#{prefix}/bin/mongod") }
        # checksum "ae786716f9fe274b049dc2d2f5ca4ede8d1e1f48f2ceecc51685e99053b1176f"
      end

      bash "install-mongo" do
        creates "#{prefix}/bin/mongod"
        cwd src
        code <<-SH
          tar xfz mongodb-linux-x86_64-2.0.4.tgz
          cd mongodb-linux-x86_64-2.0.4/bin
          cp * #{prefix}/bin/
        SH
      end
    when "i686"
      remote_file "#{src}/mongodb-linux-i686-2.0.4.tgz" do
        source "http://fastdl.mongodb.org/linux/mongodb-linux-i686-2.0.4.tgz"
        # checksum "eb0c44939fbedbec19fa15040c7904fc55d1be42161f921ecc4aa266879eb8fb"
      end

      bash "install-mongo" do
        creates "#{prefix}/bin/mongod"
        cwd src
        code <<-SH
          tar xfz mongodb-linux-i686-2.0.4.tgz
          cd mongodb-linux-i686-2.0.4/bin
          cp * #{prefix}/bin/
        SH
      end
    end

    user node[:mongodb][:user] do
      system true
    end

    # create data directory
    directory "#{node[:mongodb][:dbpath]}/#{name}" do
      owner node[:mongodb][:user]
      group node[:mongodb][:user]
      recursive true
    end

    # create log directory
    directory "#{node[:mongodb][:logpath]}/#{name}" do
      owner node[:mongodb][:user]
      group node[:mongodb][:user]
      recursive true
    end

    # mongo config
    template "/etc/mongodb-#{name}.conf" do
      source "mongodb.conf.erb"
      owner node[:mongodb][:user]
      group node[:mongodb][:user]
      variables({
        :name => name,
        :port => port
      })
      mode "0644"
      notifies :restart, "service[mongodb-#{name}]"
    end

    # upstart service config file
    template "/etc/init/mongodb-#{name}.conf" do
      source "mongodb.service.conf.erb"
      variables({
        :name => name,
        :port => port,
        :prefix => prefix
      })
      notifies :restart, "service[mongodb-#{name}]"
    end

    service "mongodb-#{name}" do
      provider Chef::Provider::Service::Upstart
      restart_command "stop mongodb-#{name}; sleep 1; start mongodb-#{name}"
      supports :status => true, :restart => true
      action [ :enable, :start ]
    end
  else
    service "mongodb-#{name}" do
      action [ :stop, :disable ]
    end # /service
  end # /if params[:enable]
end # /define
