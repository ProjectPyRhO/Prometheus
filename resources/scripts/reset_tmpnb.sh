#!/bin/sh

#sudo docker stop $(sudo docker ps -a -q)
#sudo docker rm $(sudo docker ps -a -q)
sudo docker stop proxy
sudo docker rm proxy
sudo docker stop tmpnb
sudo docker rm tmpnb

# ./prometheus.sh