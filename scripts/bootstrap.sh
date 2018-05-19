#!/bin/bash -e
set -o pipefail

echo "Installando Ansible..."
sudo apt update -y
sudo apt install -y software-properties-common python-software-properties
echo -ne '\n' | sudo add-apt-repository ppa:ansible/ansible
sudo apt update
sudo apt install -y ansible

echo "Installando Vagrant..."
curl -O https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
sudo  dpkg -i vagrant_2.1.1_x86_64.deb
rm vagrant_2.1.1_x86_64.deb
vagrant plugin install vagrant-disksize

echo "Instalando VirtualBox..."
sudo apt install -y virtualbox
