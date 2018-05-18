PWD = $(shell pwd)
VENV ?= $(PWD)/.venv
FROM ?= ubuntu:xenial
ROLE ?= test

PATH := $(VENV)/bin:$(shell printenv PATH)
SHELL := env PATH=$(PATH) /bin/bash

all: docker.build_base docker.run-build

## Build base docker image
docker.build_base:
	docker build \
		--tag ansible-docker-weirdness/ubuntu:xenial \
		-f Dockerfile.base \
		--build-arg from=ubuntu:xenial \
		.

## Build docker image using run and commit
docker.run-build: $(VENV) .docker-cache/apt
	rm -f $(PWD)/.$(ROLE).cid
	docker run \
		--privileged \
		--cidfile $(PWD)/.$(ROLE).cid \
		--volume $(PWD)/.docker-cache/apt:/var/cache/apt \
		--volume $(PWD):/build \
		ansible-docker-weirdness/$(FROM) \
		make provision VENV=/build-venv

## Build docker image
docker.build: $(VENV)
	docker build \
		--tag ansible-docker-weirdness/$(ROLE):latest \
		-f Dockerfile.ansible-role \
		--build-arg role=$(ROLE) \
		--build-arg from=$(FROM) \
		.

## Provision localhost
# DO NOT RUN IT on your laptop. Run only inside docker, vagrant, or EC2
# Usage:    make provision
provision: $(VENV)
	cd ansible && ansible-playbook \
		--inventory inventories/localhost \
		--extra-vars pwd=$(PWD) \
		--extra-vars role=$(ROLE) \
		--tags build \
		$(EXTRAS) \
		playbooks/provision.yml

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
