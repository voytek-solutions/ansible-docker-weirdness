# The Fix

Ansible comes with "docker" connection plugin which makes it very simple to connect
to docker container.

Now, we can simply run:

```BASH
# prep base image for the experiment
make docker.build_base
# this will error as expected - not-existing-service not found
make docker.build
```

and what we will end up with is a tagged docker image that was build using ansible
and mounted volume for apt cache. Simple
