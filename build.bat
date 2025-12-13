REM HoloISO Builder Script
REM This script builds the Docker image and runs the HoloISO build process inside a container with the release metadata.

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do set TIMESTAMP=%%I
docker build --build-arg CACHE_BUST=%TIMESTAMP% -t holoiso-build .

docker run -it -v "%cd%\holoiso-images:/mnt/holoiso-images" --privileged holoiso-build
pause
