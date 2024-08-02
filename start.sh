#!/usr/bin/env bash

# for GUI to work
xhost +local:docker

# get the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker build -t zathura . \
&& docker run -it \
--env DISPLAY=$DISPLAY \
--volume /tmp/.X11-unix:/tmp/.X11-unix \
--volume $DIR:/app \
zathura:latest
