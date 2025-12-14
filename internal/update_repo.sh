#!/bin/bash

# WARNING, THIS SCRIPT IS ONLY FOR UPDATING THE REPOSITORY ITSELF. UNLESS YOU KNOW WHAT YOU'RE DOING, RUN "build.sh" INSTEAD.

TIMESTAMP=$(date +%Y%m%d%H%M%S)
docker build --build-arg CACHE_BUST=$TIMESTAMP -t holoiso-build .

docker run -it -v "/var/www/holoiso/holoiso-images:/mnt/holoiso-images" --privileged holoiso-build
