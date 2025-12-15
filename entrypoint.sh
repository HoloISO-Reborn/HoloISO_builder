#!/bin/bash
sudo /home/build/buildroot/build.sh \
    --flavor "%BRANCH%" \
    --snapshot-ver "cos-v1" \
    --workdir "build" \
    --output-dir "/mnt/holoiso-images" \
    --add-release
sudo /home/build/installer-image-beta/build.sh \
    --branch "%BRANCH%" \
    --output-dir "/mnt/holoiso-images" \
    --offline \
    --images "/mnt/holoiso-images/holoiso-installer/%BRANCH%"