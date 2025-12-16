REM HoloISO Builder Script
REM This script builds the Docker image and runs the HoloISO build process inside a container with the release metadata.

set SKIP_UPDATE_BUILD=0
set SKIP_INSTALLER_BUILD=0
set OUTPUT_DIR=""

setlocal enabledelayedexpansion
for %%A in (%*) do (
    if "%%~A"=="--skip-update-build" set SKIP_UPDATE_BUILD=1
    if "%%~A"=="--skip-installer-build" set SKIP_INSTALLER_BUILD=1
    if "%%~A"=="--output" set OUTPUT_DIR=%%~B
    if "%%~A"=="--branch" set BRANCH=%%~B
)

if %OUTPUT_DIR%=="" (
    set OUTPUT_DIR=%cd%\holoiso-images
)
if "%BRANCH%"=="" (
    set BRANCH=beta
)

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do set TIMESTAMP=%%I
docker build --build-arg CACHE_BUST=%TIMESTAMP% --build-arg BRANCH="%BRANCH%" --build-arg SKIP_UPDATE_BUILD=%SKIP_UPDATE_BUILD% --build-arg SKIP_INSTALLER_BUILD=%SKIP_INSTALLER_BUILD% -t holoiso-build .
docker run -it -v "%OUTPUT_DIR%:/mnt/holoiso-images" --privileged holoiso-build
pause
