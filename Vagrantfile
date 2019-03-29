# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
settings = YAML.load_file('config.yml')
 
Vagrant.configure("2") do |config|

  # Ubuntu 18.04 with env files
  config.vm.box = "ubuntu/bionic64"

  # Ports
  config.vm.network "forwarded_port", guest: 4200, host: 4200, host_ip: "127.0.0.1"
  settings['ports'].each do |ports|
    config.vm.network "forwarded_port", guest: ports['guest'], host: ports['host'], host_ip: "127.0.0.1"
  end

  # Sync folders
  if settings['nfs']
    config.vm.network "private_network", type: "dhcp"
    config.vm.synced_folder "./vhosts_apache/", "/etc/apache2/sites-available/", type: "nfs"
    config.vm.synced_folder "./vhosts_nginx/", "/etc/nginx/sites-available/", type: "nfs"
    config.vm.synced_folder "./homepage/", "/home/vagrant/homepage/", type: "nfs"
  else
    config.vm.synced_folder "./vhosts_apache/", "/etc/apache2/sites-available/"
    config.vm.synced_folder "./vhosts_nginx/", "/etc/nginx/sites-available/"
    config.vm.synced_folder "./homepage/", "/home/vagrant/homepage/"
  end
  settings['folders'].each do |folders|
    if settings['nfs']
      config.vm.synced_folder folders['host'], folders['guest'], type: "nfs"
    else
      config.vm.synced_folder folders['host'], folders['guest']
    end
  end

  # Provision
  config.vm.provision "shell", path: "provision.sh"
  config.vm.provision "shell", inline: "service apache2 restart", run: "always"

end
