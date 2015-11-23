#!/usr/bin/env bash
sudo yum groupinstall -y 'Development Tools' 
sudo yum install -y wget kernel-devel

# This is for an issue w/ Vagrant keys: http://superuser.com/questions/745881/how-to-authenticate-to-a-vm-using-vagrant-up
sudo mkdir -p /home/vagrant/.ssh
sudo wget --no-check-certificate \
    'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant /home/vagrant/.ssh
sudo chmod -R go-rwsx /home/vagrant/.ssh

# Mount and install vbox guest additions
cd /tmp
sudo mkdir /tmp/isomount
sudo mount -t iso9660 -o loop /home/vagrant/VBoxGuestAdditions.iso /tmp/isomount

# Install the drivers
sudo /tmp/isomount/VBoxLinuxAdditions.run

# Cleanup
sudo umount isomount
sudo rm -rf isomount /home/vagrant/VBoxGuestAdditions.iso
