# Configuration parameters
CULL_PERIOD ?= 60
CULL_TIMEOUT ?= 600
CULL_MAX ?= 3600
#LOGGING ?= debug
POOL_SIZE ?= 5
DOCKER_HOST ?= 127.0.0.1
DEMO_IMAGE ?= pyrho/minimal
#TOKEN ?= $( shell head -c 30 /dev/urandom | xxd -p )

.PHONY: setup start restart proxy-image tmpnb-image redirect token launch dev open log-proxy log-tmpnb squash update update-all clean nuke uninstall #upload


#TAG ?= e736784a1a8f
# https://github.com/jupyter/docker-demo-images/blob/master/Makefile
# https://github.com/jupyter/tmpnb/blob/master/Makefile

help:
	@cat Makefile
# make go DEMO_IMAGE=jupyter/demo
# Alternatively set environment variables
# FOOBAR=1 make

setup:
	#./resources/scripts/setup_docker.sh
	#sudo apt-get update && sudo apt-get upgrade
	#sudo apt-get install apt-transport-https ca-certificates
	#sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	#echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee -a /etc/apt/sources.list.d/docker.list
	#sudo apt-get install linux-image-extra-$(shell uname -r) linux-image-extra-virtual
	#sudo apt-get update
	#sudo apt-get purge lxc-docker
	#sudo apt-get install docker-engine
	sudo curl -sSL https://get.docker.com/ | sh
	# To start at boot
	sudo systemctl enable docker
	# Add group docker to current user
	sudo usermod -a -G docker $(USER)
	# Reboot for group membership
	#sudo reboot
	# Alternatively activate group changes and start docker
	newgrp docker
	sudo service docker start

start:
	sudo service docker start

restart:
	-docker stop `docker ps -aq`
	-docker rm -fv `docker ps -aq`
	sudo service docker restart

image: Dockerfile
	docker build -t $(DEMO_IMAGE) .

demo:
	docker run -p 8888:8888 -it $(DEMO_IMAGE)

proxy-image:
	docker pull jupyter/configurable-http-proxy

tmpnb-image:
	-git clone https://github.com/jupyter/tmpnb.git
	-yes | cp resources/_templates/ga.html tmpnb/templates/ga.html
	-docker build -t jupyter/tmpnb -f tmpnb/Dockerfile tmpnb
# -i '' in OS X
#-sed -i -e 's/UA-56096826-1/UA-82943814-1/g' tmpnb/templates/ga.html

images: image proxy-image tmpnb-image

redirect:
	sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8000
	sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j LOG --log-prefix='[TMPNB] '

token:
	$(eval TOKEN := $(shell head -c 30 /dev/urandom | xxd -p))
	echo $(TOKEN)
#token: 	TOKEN := $( shell head -c 30 /dev/urandom | xxd -p )
# export TOKEN $( shell head -c 30 /dev/urandom | xxd -p )

#proxy: proxy-image token
proxy:
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) --name proxy \
		jupyter/configurable-http-proxy --default-target http://$(DOCKER_HOST):9999

#tmpnb: tmpnb-image token
tmpnb:
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) --name tmpnb \
		-v /var/run/docker.sock:/docker.sock jupyter/tmpnb python orchestrate.py \
		--image=$(DEMO_IMAGE) --cull_timeout=$(CULL_TIMEOUT) --cull_period=$(CULL_PERIOD) \
		--pool_size=$(POOL_SIZE) --cull_max=$(CULL_MAX) \
		--redirect_uri="/notebooks/Prometheus.ipynb" \
		--command="jupyter notebook --NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port} --no-browser"
# --logging=$(LOGGING)

launch:
	./resources/scripts/launch.sh

run:
	sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8000
	sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j LOG --log-prefix='[TMPNB] '
	#TOKEN:=$(shell head -c 30 /dev/urandom | xxd -p)
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) --name=proxy \
    jupyter/configurable-http-proxy --default-target http://$(DOCKER_HOST):9999 \
    --port=8000 --api-port=8001
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) --name=tmpnb \
    -e CONFIGPROXY_ENDPOINT=http://$(DOCKER_HOST):8001 \
    -v /var/run/docker.sock:/docker.sock \
    jupyter/tmpnb python orchestrate.py --image=$(DEMO_IMAGE) \
		--pool_size=$(POOL_SIZE) --mem_limit=$(MEM_LIMIT) --cpu_shares=$(CPU_SHARES) \
    --cull_timeout=$(CULL_TIMEOUT) --cull_period=$(CULL_PERIOD) --cull_max=$(CULL_MAX) \
    --redirect_uri="/notebooks/Prometheus.ipynb" \
    --command="jupyter notebook --NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port} --no-browser"

go: redirect token proxy tmpnb image
	redirect
	token
	proxy
	tmpnb

dev: ARGS?=
dev: clean proxy tmpnb open
	docker run --rm -it -p 8888:8888 $(DEMO_IMAGE) $(ARGS)

open:
	docker ps | grep tmpnb
	docker ps | grep $(DEMO_IMAGE)
	-open http:`echo $(DOCKER_HOST) | cut -d":" -f2`:8000

log-proxy:
	docker logs -f proxy

log-tmpnb:
	docker logs -f tmpnb

squash:
	ID:=$(shell docker run -d $(DEMO_IMAGE) /bin/bash)
	docker export $(ID) | docker import – prometheus

update:
	sudo apt-get update
	sudo apt-get upgrade docker-engine

update-all:
	sudo apt-get update
	sudo apt-get upgrade

nuke: clean
	-docker rmi $(DEMO_IMAGE)

clean:
	-docker stop `docker ps -aq`
	-docker rm -fv `docker ps -aq`
	-docker images -q --filter "dangling=true" | xargs docker rmi

uninstall:
	#sudo apt-get purge docker-engine
	sudo apt-get autoremove --purge docker-engine
	rm -rf /var/lib/docker

# Future use for pushing to docker hub
#update-tag:
#	./update-dockerfile-includes $(TAG)

#upload:
#	docker push $(DEMO_IMAGE)
