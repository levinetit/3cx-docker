#!/bin/bash

VERSION=20.0.1.731
USER=levinetit
HOSTNAME=levinetit.3cx.ro

docker run \
        -d \
		--privileged \
        --name 3cx \
        --hostname ${HOSTNAME} \
		--security-opt apparmor=unconfined \
		--network host \
        --restart unless-stopped \
        -v 3cx_backup:/srv/backup \
        -v 3cx_recordings:/srv/recordings \
        -v 3cx_log:/var/log \
        --cap-add SYS_ADMIN \
        --cap-add NET_ADMIN \
        ${USER}/3cx:${VERSION}
