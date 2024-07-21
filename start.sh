#!/usr/bin/env bash

# for GUI to work
xhost +local:docker

docker build -t zathura .

docker run -it \
--env DISPLAY=$DISPLAY \
--volume /tmp/.X11-unix:/tmp/.X11-unix \
zathura
