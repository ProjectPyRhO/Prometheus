#!/bin/sh
# https://docs.docker.com/engine/installation/linux/ubuntulinux/

sudo apt-get update && sudo apt-get upgrade
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# sudo echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" >> /etc/apt/sources.list.d/docker.list
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee -a /etc/apt/sources.list.d/docker.list

sudo apt-get install linux-image-extra-$(uname -r)
sudo apt-get update
sudo apt-get purge lxc-docker

sudo apt-get install docker-engine

# To start at boot
sudo systemctl enable docker

# Add group docker to current user
sudo usermod -a -G docker $USER

sudo reboot
