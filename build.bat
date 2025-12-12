for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do set TIMESTAMP=%%I
docker build --build-arg CACHE_BUST=%TIMESTAMP% -t holoiso-build .
docker run -it -v "%cd%\out:/mnt/out" --privileged holoiso-build
pause
