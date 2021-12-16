#!/bin/sh

docker build -t ec2019 .
docker run --ipc="private" --privileged -e DISPLAY=$DISPLAY -v "$HOME"/.Xauthority:/root/.Xauthority -v /tmp/.X11-unix:/tmp/.X11-unix --volume $(pwd)/Memory:/root/m -it ec2019 

