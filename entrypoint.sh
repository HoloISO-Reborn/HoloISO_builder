#!/bin/bash

branch=$(cat /home/build/branch)
skip_update_build=$(cat /home/build/skip_update_build)
skip_installer_build=$(cat /home/build/skip_installer_build)
type=$(cat /home/build/type)

if [[ "$skip_update_build" == "1" && "$skip_installer_build" == "1" ]]; then
    echo "Both build steps are skipped dummass."
    exit 0
fi

# if not /home/build/skip_update_build is 1, run the builder update script
if [[ "$skip_update_build" != "1" && "$type" != "online" ]]; then
    sudo /home/build/buildroot/build.sh \
        --flavor $branch \
        --snapshot-ver "cos-v1" \
        --workdir "build" \
        --output-dir "/mnt/holoiso-images/holoiso-images/$branch" \
        --add-release
fi

if [[ "$skip_installer_build" != "1" ]]; then
    sudo /home/build/installer-image-beta/build.sh \
        --branch $branch \
        --output-dir "/mnt/holoiso-images/holoiso-installer/$branch" \
        --offline \
        --images "/mnt/holoiso-images/holoiso-images/$branch" \
        --type "$(cat /home/build/type)"
fi