#!/usr/bin/env bash
set -e

./mvnw clean package
BUILD_VERSION=$(cat VERSION)
docker build --platform linux/amd64 -t springdeveloper/hello-world:$BUILD_VERSION -f ./docker/Dockerfile .
docker push springdeveloper/hello-world:$BUILD_VERSION
