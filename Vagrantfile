# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # build from ubuntu 14.04 base image
  config.vm.box = "ubuntu/trusty64"
  # check box up-to-date
  config.vm.box_check_update = true
  # allow access to default Jupyter port
  config.vm.network "forwarded_port", guest: 8888, host: 8888
  # try open ports for Jupyter kernel ZMQ
  for i in 60001..60005
    config.vm.network "forwarded_port", guest: i, host: i, autocorrect: true
  end
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  # share the notebooks directory
  config.vm.synced_folder "./notebooks", "/vagrant_notebooks"
  # set default memory and other vm settings
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
  end
  # config.push.define "atlas" do |push|
  #   push.app = "gawbul/ReproPhylo"
  # end
  # setup provisioning via shell script
  config.vm.provision "shell", path: "bootstrap.sh"
end
