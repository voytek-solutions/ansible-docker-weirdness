
simply run

```BASH
# prep base image for the experiment
make docker.build_base
# this will error as expected - not-existing-service not found
make docker.build
# this will error in a interesting way...
make docker.run-build
```




`make docker.build` errors as expected

```
TASK [setup a service] *********************************************************
fatal: [localhost]: FAILED! => {"changed": false, "msg": "Could not find the requested service not-existing-service: host"}
	to retry, use: --limit @/build/ansible/playbooks/provision.retry
```

but the `make docker.run-build` gives that error

```
TASK [setup a service] *********************************************************
fatal: [localhost]: FAILED! => {"changed": false, "msg": "Unsupported parameters for (make) module: enabled, name Supported parameters include: chdir, file, params, target"}
	to retry, use: --limit @/build/ansible/playbooks/provision.retry
```




## The Problem

The "problem" is simple, when I run "make" using `docker run ...` make becomes
pid 1 process, and Ansible thinks that "make" is the process manager, ergo "make"
module should be used to satisfy the "service" task...




## The Fix

Go to "[the fix](the-fix)" folder to see how I provision docker images with ansible.
