# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = true
  config.vm.network "forwarded_port", guest: 8888, host: 8888
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  config.vm.synced_folder "./notebooks", "/vagrant_notebooks"
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
  end
  # config.push.define "atlas" do |push|
  #   push.app = "gawbul/ReproPhylo"
  # end
  config.vm.provision "shell", path: "bootstrap.sh"
  # config.vm.provision "shell", path: "notepad.sh"
end
