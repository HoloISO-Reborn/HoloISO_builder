#!/bin/bash

#TODO CHECK IF WORKS AS INTENDED WITH ARGS
# HoloISO Builder Script
# This script builds the Docker image and runs the HoloISO build process inside a container with the release metadata.


SKIP_UPDATE_BUILD=0
SKIP_INSTALLER_BUILD=0
OUTPUT_DIR=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --skip-update-build)
            SKIP_UPDATE_BUILD=1
            shift
            ;;
        --skip-installer-build)
            SKIP_INSTALLER_BUILD=1
            shift
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift
            shift
            ;;
        --branch)
            BRANCH="$2"
            shift
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="$(pwd)/holoiso-images"
fi

if [[ -z "$BRANCH" ]]; then
    BRANCH="beta"
fi

TIMESTAMP=$(date +%Y%m%d%H%M%S)

docker build --build-arg CACHE_BUST=$TIMESTAMP \
             --build-arg BRANCH="$BRANCH" \
             --build-arg SKIP_UPDATE_BUILD=$SKIP_UPDATE_BUILD \
             --build-arg SKIP_INSTALLER_BUILD=$SKIP_INSTALLER_BUILD \
             -t holoiso-build .

docker run -v "$OUTPUT_DIR:/mnt/holoiso-images" --privileged holoiso-build
