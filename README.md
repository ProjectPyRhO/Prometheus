Prometheus: Modelling as a Service
==================================

This is a repository for building a customised tmpnb server for optogenetics with PyRhO installed and configured.

Quickstart Prometheus
---------------------


#### Create an account to run the portal and disable root access
See [this guide](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04) for details including generating ssh keys.

```bash
adduser monty
gpasswd -a monty sudo
sudo nano /etc/ssh/sshd_config
```

Eidt the sshd_config file to disable root login:
> PermitRootLogin no

Then restart the ssh daemon:

`service ssh restart`

Finally update the system, install docker, build the image and launch the server!

```bash
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install make
git clone https://github.com/ProjectPyRhO/Prometheus.git
cd Prometheus
make setup
make image
make launch
```

Interactive Docker image
------------------------

#### To run the PyRhO docker image:

```bash
sudo service docker start
docker build -t pyrho/minimal .
docker run -p 8888:8888 -it pyrho/minimal /bin/bash
```

Useful commands
---------------

#### Clean docker images

`make clean`

Alternatively:

```bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rm $(docker ps -qa --no-trunc --filter "status=exited")
docker rmi $(docker images -q --no-trunc --filter "dangling=true")
```

#### Check logs

```bash
make log-proxy
make log-tmpnb
sudo iptables -L
```

N.B. After an os update it may be necessary to run:
`sudo apt-get install linux-image-extra-$(uname -r)`
