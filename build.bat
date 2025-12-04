docker build -t holoiso-build .
docker run -it -v "%cd%\out:/mnt/out" --privileged holoiso-build
pause
