#!/bin/sh

docker build -t ec2019 .
docker run --volume $(pwd)/Memory:/root/m -it ec2019 

