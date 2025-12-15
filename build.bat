REM HoloISO Builder Script
REM This script builds the Docker image and runs the HoloISO build process inside a container with the release metadata.

set SKIP_UPDATE_BUILD=0

for %%A in (%*) do (
    if "%%~A"=="--skip-update-build" set SKIP_UPDATE_BUILD=1
    if "%%~A"=="--skip-installer-build" set SKIP_INSTALLER_BUILD=1
)

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do set TIMESTAMP=%%I
docker build --build-arg CACHE_BUST=%TIMESTAMP% --build-arg BRANCH="beta" --build-arg SKIP_UPDATE_BUILD=%SKIP_UPDATE_BUILD% --build-arg SKIP_INSTALLER_BUILD=%SKIP_INSTALLER_BUILD% -t holoiso-build .
docker run -it -v "%cd%\holoiso-images:/mnt/holoiso-images" --privileged holoiso-build
pause
