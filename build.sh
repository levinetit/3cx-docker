#!/bin/bash

set -e

VERSION=20.0.8.1109
USER=levinetit

# Sterge imaginea existenta daca exista
docker rmi ${USER}/3cx:${VERSION} 2>/dev/null || true

docker build \
        --force-rm \
        --no-cache \
        --build-arg PACKAGE_VERSION=${VERSION} \
        --build-arg DEBIAN_VERSION=bookworm \
        --build-arg BUILD_STRING="$(date -u)" \
        --build-arg BUILD_DATE="$(date +%d-%m-%Y)" \
        --build-arg BUILD_TIME="$(date +%H:%M:%S)" \
        -t ${USER}/3cx:${VERSION} .

docker push ${USER}/3cx:${VERSION} || echo "Push failed (no credentials) - image available locally"

echo "Build complet: ${USER}/3cx:${VERSION}"
