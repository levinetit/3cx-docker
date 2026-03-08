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
        -t 3cx_stage1 .

# Curata container stage1 existent daca ramane din build anterior
docker rm -f 3cx_stage1_c 2>/dev/null || true

docker run \
        -d \
        --privileged \
        --cgroupns=host \
        --name 3cx_stage1_c 3cx_stage1

# Asteapta systemd sa fie complet initializat
echo "Waiting for systemd to be ready..."
until docker exec 3cx_stage1_c systemctl is-system-running 2>/dev/null | grep -qE "running|degraded"; do
    sleep 3
done
echo "systemd ready."

docker exec 3cx_stage1_c bash -c \
        "   systemctl mask systemd-logind console-getty.service container-getty@.service \
                getty-static.service getty@.service serial-getty@.service getty.target \
         && apt-get update \
         && echo 1 | apt-get -y install 3cxpbx=${VERSION} \
         && systemctl enable nginx postgresql 3cx_fix_perms.service 3cx_autosetup.service \
         && (systemctl enable exim4 2>/dev/null || true)"

docker stop 3cx_stage1_c

docker commit 3cx_stage1_c ${USER}/3cx:${VERSION}

docker push ${USER}/3cx:${VERSION} || echo "Push failed (no credentials) - image available locally"

docker rm 3cx_stage1_c
docker rmi 3cx_stage1

echo "Build complet: ${USER}/3cx:${VERSION}"
