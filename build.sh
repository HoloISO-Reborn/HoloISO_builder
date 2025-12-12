docker build -t holoiso-build .
docker run -it --rm -v ./out:/mnt/out --privileged holoiso-build
