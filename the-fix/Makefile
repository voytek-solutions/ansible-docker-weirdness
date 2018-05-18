PWD = $(shell pwd)
VENV ?= $(PWD)/.venv
FROM ?= ubuntu:xenial
ROLE ?= test

PATH := $(VENV)/bin:$(PWD)/vendor:$(shell printenv PATH)
SHELL := env PATH=$(PATH) /bin/bash

all: docker.build_base docker.build

## Build base docker image
docker.build_base:
	docker build \
		--tag ansible-docker/ubuntu:xenial \
		-f Dockerfile.base \
		--build-arg from=ubuntu:xenial \
		.

## Build docker image using run and commit
docker.build: $(VENV) .docker-cache/apt .cid/$(ROLE)
	$(MAKE) docker.provision ROLE=$(ROLE)
	docker commit $$(cat $(PWD)/.cid/$(ROLE)) ansible-docker/$(ROLE):latest
	$(MAKE) docker.stop ROLE=$(ROLE)

## Provision localhost
# DO NOT RUN IT on your laptop. Run only inside docker, vagrant, or EC2
# Usage:    make provision
docker.provision: $(VENV)
	cd ansible && ansible-playbook \
		--inventory inventories/docker \
		--extra-vars pwd=$(PWD) \
		--extra-vars role=$(ROLE) \
		--tags build \
		$(EXTRAS) \
		playbooks/provision.yml

docker.stop:
	docker stop $$(cat $(PWD)/.cid/$(ROLE)) && rm -f $(PWD)/.cid/$(ROLE)

.cid/$(ROLE):
	mkdir -p .cid
	docker run \
		-d \
		--privileged \
		--cidfile $(PWD)/.cid/$(ROLE) \
		--volume $(PWD)/.docker-cache/apt:/var/cache/apt \
		--volume $(PWD):/build \
		ansible-docker/$(FROM)

# ensure apt cache folder
.docker-cache/apt:
	mkdir -p .docker-cache/apt

# install dependencies in virtualenv
$(VENV):
	@which virtualenv > /dev/null || (\
		echo "please install virtualenv: http://docs.python-guide.org/en/latest/dev/virtualenvs/" \
		&& exit 1 \
	)
	virtualenv --system-site-packages $(VENV)
	$(VENV)/bin/pip install -r $(PWD)/.pip --ignore-installed
	virtualenv --relocatable $(VENV)
