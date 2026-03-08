#!/bin/bash


VERSION=20.0.8.1109
USER=levinetit
HOSTNAME=levinetit.3cx.ro

docker run \
        -d \
        --privileged \
        --cgroupns=host \
        --name 3cx \
        --hostname ${HOSTNAME} \
        --restart unless-stopped \
        -v /home/docker-apps/3cx/3cx_backup:/srv/backup \
        -v /home/docker-apps/3cx/3cx_recordings:/srv/recordings \
        -v /home/docker-apps/3cx/3cx_log:/var/log \
        -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
        -p 5015:5015 \
        -p 5001:5001 \
        ${USER}/3cx:${VERSION}
