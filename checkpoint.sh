#!/usr/bin/env bash
set -e

./mvnw clean package
docker build -t springdeveloper/hello-world:builder-amd64 .
docker run -d --privileged --rm --name=hello-world --ulimit nofile=1024 -p 8080:8080 -v $(pwd)/target:/opt/mnt springdeveloper/hello-world:builder-amd64
echo "Please wait, creating the checkpoint..."
sleep 10
docker commit --change='ENTRYPOINT ["/opt/app/entrypoint.sh"]' $(docker ps -qf "name=hello-world") springdeveloper/hello-world:checkpoint-amd64
docker kill $(docker ps -qf "name=hello-world")
