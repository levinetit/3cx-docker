#!/bin/bash

VERSION=20.0.8.1109
USER=levinetit
HOSTNAME=levinetit.3cx.ro
NETWORK=apps
IP=172.88.88.50

# Oprire si stergere container existent (daca exista)
if docker inspect 3cx &>/dev/null; then
    echo "Oprire container 3cx existent..."
    docker stop 3cx && docker rm 3cx
fi

docker run \
        -d \
        --privileged \
        --cgroupns=host \
        --name 3cx \
        --hostname ${HOSTNAME} \
        --restart unless-stopped \
        --network ${NETWORK} \
        --ip ${IP} \
        -v /home/docker-apps/3cx/3cx_backup:/srv/backup \
        -v /home/docker-apps/3cx/3cx_recordings:/srv/recordings \
        -v /home/docker-apps/3cx/3cx_log:/var/log \
        -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
        -p 5015:5015 \
        -p 5001:5001 \
        ${USER}/3cx:${VERSION}

echo "Container 3cx pornit cu IP ${IP} in reteaua ${NETWORK}."
echo "Web wizard disponibil la: http://${IP}:5015"
