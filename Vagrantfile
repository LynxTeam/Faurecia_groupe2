# -*- mode: ruby -*-
# vi: set ft=ruby sw=2 st=2 et :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/buster64"
  config.vm.box_check_update = false

  # Limiter la RAM des VM
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "752"
    vb.gui = false
  end

  # Mettre en place un cache pour APT
  # config.vm.synced_folder 'v-cache', '/var/cache/apt'
  #
  5.times do |idx|
    config.vm.define "s#{idx}.infra" do |machine|
      machine.vm.hostname = "s#{idx}.infra" 
      if idx == 0 
        machine.vm.network "private_network", ip: "192.168.50.10"
        machine.vm.network "forwarded_port", guest: 80, host: 1080
        machine.vm.network "forwarded_port", guest: 8080, host: 8080
      else
        machine.vm.network "private_network", 
          ip: "192.168.50.#{idx * 10 + 10}", auto_config: false
      end # if
    end # config
#
   if idx == 0
     config.vm.provision "shell", path: "provision.1.sh", env: {"PERFORM_DHCLIENT" => "false"}
   else
     config.vm.provision "shell", path: "provision.1.sh", env: {"PERFORM_DHCLIENT" => "true"}
   end # times
 end
 
 # config node0 
   config.vm.define 'node0' do |machine|
     machine.vm.hostname = 'node0'
     machine.vm.network "private_network", ip: "192.168.50.250"
   end
     config.vm.provision "shell", path: "provision.sh", env: {"PERFORM_DHCLIENT" => "false"} 
 end
#end
