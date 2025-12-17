#!/bin/bash

#./update_build_beta.sh <branch>

cd /var/HoloISO_builder || exit 1
git stash
git pull
chmod +x /var/HoloISO_builder/build.sh /var/HoloISO_builder/internal/update_build_beta.sh
/var/HoloISO_builder/build.sh --output /var/www/holoiso --branch $1
docker kill $(docker ps -q --filter ancestor=holoiso-build)
docker rm $(docker ps -a -q --filter ancestor=holoiso-build)
