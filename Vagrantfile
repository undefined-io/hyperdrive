# -*- mode: ruby -*-
# vi: set ft=ruby tabstop=2 expandtab shiftwidth=2 softtabstop=2 :

VAGRANT_MEMSIZE = ENV['STARPHLEET_VAGRANT_MEMSIZE'] || '8192'
SHIP_NAME = 'ship'

Vagrant::Config.run do |config|
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  config.vm.provision :shell, :path => "bootstrap", :args => "\"#{ENV['STARPHLEET_ROOT']}\" \"#{ENV['STARPHLEET_DATA_ROOT']}\" \"#{ENV['STARPHLEET_GIT']}\" \"#{ENV['STARPHLEET_BRANCH']}\""
end

Vagrant::VERSION >= "1.1.0" and Vagrant.configure("2") do |config|
  config.vm.hostname = SHIP_NAME
  config.vm.synced_folder "~", "/hosthome"

  config.vm.provider :vmware_fusion do |f, override|
    override.vm.network "public_network"
    override.vm.box = ENV['BOX_NAME'] || 'saucy-vmware'
    override.vm.box_url = "http://brennovich.s3.amazonaws.com/saucy64_vmware_fusion.box"
    f.vmx["displayName"] = SHIP_NAME
    f.vmx["memsize"] = VAGRANT_MEMSIZE 
  end

  config.vm.provider :virtualbox do |f, override|
    override.vm.network "public_network"
    override.vm.box = ENV['BOX_NAME'] || 'saucy-virtualbox'
    override.vm.box_url = "https://s3.amazonaws.com/glg_starphleet/saucy-13.10-vbox-4.3.6.box"
    f.vmx["displayName"] = SHIP_NAME
    f.customize ["modifyvm", :id, "--memory", VAGRANT_MEMSIZE]
  end

  config.vm.provider :parallels do |f, override|
    override.vm.box = ENV['BOX_NAME'] || 'saucy-parallels'
    override.vm.box_url = "https://s3.amazonaws.com/glg_starphleet/saucy-server-parallels-9-amd64-vagrant-1.4.3.box"
    f.name = SHIP_NAME
    f.customize ["set", :id, "--memsize", VAGRANT_MEMSIZE]
  end
end
