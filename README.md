Prometheus: Modelling as a Service
==================================

This is a repository for building a customised tmpnb server for optogenetics with PyRhO installed and configured.

Quickstart Prometheus
---------------------
`sudo apt-get update && sudo apt-get upgrade`

`sudo apt-get install make`

`git clone https://github.com/ProjectPyRhO/Prometheus.git`

`cd Prometheus`

#### Create an account to run the portal and disable root access
See [this guide](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04) for details including generating ssh keys.

`adduser monty`

`gpasswd -a monty sudo`

`sudo nano /etc/ssh/sshd_config`

> PermitRootLogin no

`service ssh restart`

```bash
git clone https://github.com/ProjectPyRhO/Prometheus

chown -R monty:monty Prometheus/*

cd Prometheus

chmod a+x *.sh

./setup_docker.sh

./prometheus.sh
```

Alternatively, docker can be installed with `sudo curl -sSL https://get.docker.com/ | sh`. 

Interactive Docker image
------------------------

#### To run the PyRhO docker image:

`sudo service docker start`

`sudo docker build -t pyrho/minimal .`

`docker run -i -t pyrho/minimal /bin/bash`

Useful commands
---------------

#### Clean docker images
`sudo docker stop $(sudo docker ps -a -q)`

`sudo docker rm $(sudo docker ps -a -q)`

#### Remove old intermediate layers
`docker rm $(docker ps -qa --no-trunc --filter "status=exited")`

`docker rmi $(docker images -q --no-trunc --filter "dangling=true")`

#### Check logs
`sudo docker logs proxy`

`sudo docker logs tmpnb`

`sudo iptables -L`

After an os update it may be necessary to run:
`sudo apt-get install linux-image-extra-$(uname -r)`
