#!/usr/bin/env bash
set -e

ARCH=${TARGET_ARCH:-amd64}
if [[ !( $ARCH == 'arm64' || $ARCH == 'amd64' ) ]]; then
  echo "$ARCH is an invalid cluster architecture value, set the TARGET_ARCH env var to 'amd64' or 'arm64'"
fi
./mvnw clean package --no-transfer-progress
BUILD_VERSION=$(cat VERSION)
echo "Building image with tag $ARCH-$BUILD_VERSION"
docker build --platform linux/$ARCH -t $REGISTRY_PREFIX/hello-world:$ARCH-$BUILD_VERSION -f ./docker/$ARCH/Dockerfile .
docker push $REGISTRY_PREFIX/hello-world:$ARCH-$BUILD_VERSION
