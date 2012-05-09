# -*- mode: ruby -*-
# vi: set ft=ruby :
f = File.join(File.dirname(__FILE__), 'vm.yml')
custom = {}
File.open(f) do |file|
  require 'yaml'
  custom = YAML.load(file)
end if File.exists?(f)

Vagrant::Config.run do |config|
  config.vm.define :default do |config_default|
    config_default.vm.box = "precise64_unofficial"
    config_default.vm.box_url = "http://burned.s3.amazonaws.com/precise64_unofficial.box"
    # config.vm.boot_mode = :gui
    config_default.vm.network :hostonly, "192.168.55.10"
    # customize vm
    if custom['default']
      custom['default'].each_pair do |key, value|
        config_default.vm.customize ["modifyvm", :id, "--#{key}", value]
      end
    else
      # defaults if not customized
      config_default.vm.customize ["modifyvm", :id, "--memory", 512]
      config_default.vm.customize ["modifyvm", :id, "--cpus", 1]
    end
    # Enable provisioning with chef solo, specifying a cookbooks path (relative
    # to this Vagrantfile), and adding some recipes and/or roles.
    #
    config_default.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "chef/cookbooks"
      chef.roles_path = "chef/roles"
      chef.data_bags_path = "chef/data_bags"

      chef.run_list = %w(role[base] recipe[riaktest])

      # You may also specify custom JSON attributes:
      chef.json = {
        :ssh_user => "vagrant",
        :www_path => "/vagrant"
      }
    end
  end
end
