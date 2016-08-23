.PHONY: build dev nuke super-nuke upload

TAG ?= e736784a1a8f

help:
	@cat Makefile

update-tag:
	./update-dockerfile-includes $(TAG)

build:
	docker build -t pyrho/minimal .

dev: ARGS?=
dev:
	docker run --rm -it -p 8888:8888 pyrho/minimal $(ARGS)

upload:
	docker push pyrho/minimal

super-nuke: nuke
	-docker rmi pyrho/minimal

# Cleanup with fangs
nuke:
	-docker stop `docker ps -aq`
	-docker rm -fv `docker ps -aq`
	-docker images -q --filter "dangling=true" | xargs docker rmi
