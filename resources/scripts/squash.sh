#! /bin/sh

#sudo docker run -d pyrho/minimal
#sudo docker export pyrho/minimal | sudo docker import - pyrho/minimal:latest #squashed:new

ID=$(docker run -d pyrho/minimal /bin/bash)
docker export $ID | docker import – prometheus
