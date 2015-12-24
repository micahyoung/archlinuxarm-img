# Arch Linux Pi image builder

Build SD ready images

## From the command-line (requires root to allow mounting)
./build.sh <output dir>

## Docker (must be privileged to allow mounting)
docker build --tag alarmpi-builder . 
docker run -it --privileged -v <host output dir>:<container output dir> alarmpi-builder <container output dir>
