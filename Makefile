# Configuration parameters
CULL_PERIOD ?= 30
CULL_TIMEOUT ?= 600
CULL_MAX ?= 120
LOGGING ?= debug
POOL_SIZE ?= 5
DOCKER_HOST ?= 127.0.0.1
DEMO_IMAGE ?= pyrho/minimal

.PHONY: setup start build build-tmpnb launch dev squash nuke super-nuke upload

#TAG ?= e736784a1a8f
# https://github.com/jupyter/docker-demo-images/blob/master/Makefile

# https://github.com/jupyter/tmpnb/blob/master/Makefile

help:
	@cat Makefile
# make go DEMO_IMAGE=jupyter/demo
# Alternatively set environment variables
# FOOBAR=1 make

#update-tag:
#	./update-dockerfile-includes $(TAG)

setup:
	./resources/scripts/setup_docker.sh

start:
	sudo service docker start

build:
	docker build -t pyrho/minimal .

build-tmpnb:
	-git clone https://github.com/jupyter/tmpnb.git
	-yes | cp resources/_templates/ga.html tmpnb/templates/ga.html
	-docker build -t jupyter/tmpnb -f tmpnb/Dockerfile tmpnb
# -i '' in OS X
#-sed -i -e 's/UA-56096826-1/UA-82943814-1/g' tmpnb/templates/ga.html

images: build build-tmpnb

token:
	TOKEN:=$(shell head -c 30 /dev/urandom | xxd -p )

proxy: proxy-image token
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) \
		--name proxy \
		jupyter/configurable-http-proxy \
		--default-target http://127.0.0.1:9999

tmpnb: minimal-image tmpnb-image token
	docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$(TOKEN) --name tmpnb \
		-v /var/run/docker.sock:/docker.sock jupyter/tmpnb python orchestrate.py \
		--image=$(DEMO_IMAGE) --cull_timeout=$(CULL_TIMEOUT) --cull_period=$(CULL_PERIOD) \
		--logging=$(LOGGING) --pool_size=$(POOL_SIZE) --cull_max=$(CULL_MAX)

launch:
	./resources/scripts/launch.sh

go: token proxy tmpnb build
	token
	proxy
	tmpnb

dev: ARGS?=
dev:
	docker run --rm -it -p 8888:8888 pyrho/minimal $(ARGS)

open:
	docker ps | grep tmpnb
	docker ps | grep $(DEMO_IMAGE)
	-open http:`echo $(DOCKER_HOST) | cut -d":" -f2`:8000

log-tmpnb:
	docker logs -f tmpnb

log-proxy:
	docker logs -f proxy

squash:
	ID=$(shell docker run -d pyrho/minimal /bin/bash)
	docker export $(ID) | docker import – prometheus

update:
	sudo apt-get purge lxc-docker
	sudo apt-get update
	sudo apt-get install linux-image-extra-$(shell uname -r)
	sudo apt-get install docker-engine

upload:
	docker push pyrho/minimal

super-nuke: nuke
	-docker rmi pyrho/minimal

# Cleanup with fangs
nuke:
	-docker stop `docker ps -aq`
	-docker rm -fv `docker ps -aq`
	-docker images -q --filter "dangling=true" | xargs docker rmi
