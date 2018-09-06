# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.synced_folder ".", "/vagrant_data"
  config.vm.synced_folder "./home", "/home/vagrant"


  # # config.vm.provider "virtualbox" do |vb|
  # #    vb.gui = false
  # #    vb.cpus = 4
  # #    vb.memory = "4096"
  # #  end

  # Note that this will be both the OOD server and the SGE master
  config.vm.define "master", primary: true, autostart: true do |master|
    master.vm.hostname = "master"
    master.vm.network "forwarded_port", guest: 80, host: 8080
    master.vm.network "private_network", ip: "10.0.0.100"

    master.vm.provision "shell", inline: "cp -f /vagrant_data/hosts /etc/hosts"

    master.vm.provision "shell", path: "install_sge_master.sh"
  end

  config.vm.define "client", primary: true, autostart: true do |client|
    client.vm.hostname = "client"
    client.vm.network "private_network", ip: "10.0.0.101"

    client.vm.provision "shell", inline: "cp -f /vagrant_data/hosts /etc/hosts"

    client.vm.provision "shell", path: "install_sge_client.sh"
  end
end
