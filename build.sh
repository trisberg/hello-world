#!/usr/bin/env bash
set -e

./mvnw clean package
docker buildx build --platform linux/amd64 -t springdeveloper/hello-world:crac-job .
