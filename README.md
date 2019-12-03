# Mini-root FS for Salix

This script is used to create a mini-root file-system for Salix. The
filesystem includes only just enough software in order to run slapt-get
in it. No kernel packages are included.

You may use it to build a 32-bit mini-root FS:
```
sudo ./create-rootfs.sh i486
```

or a 64-bit one:
```
sudo ./create-rootfs.sh x86_64
```

This script is used to create the mini-root FS tarballs that are used as
sources for creating the Salix Docker images that you can find in
DockerHub:
* https://hub.docker.com/repository/docker/salixos/salix
* https://hub.docker.com/repository/docker/salixos/salix64

The resulting tarballs are placed in the docker-i486 and docker-x86_64
directories, which are in fact git submodules for the respective
Dockerfile repositories:
* https://github.com/Salix-OS/salix-docker
* https://github.com/Salix-OS/salix64-docker

