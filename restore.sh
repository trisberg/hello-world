#!/usr/bin/env bash
set -e

docker run --rm -p 8080:8080 --name hello-world springdeveloper/hello-world:checkpoint-amd64
