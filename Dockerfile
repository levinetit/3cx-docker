FROM debian:bookworm

ARG DEBIAN_VERSION=bookworm

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Pachete necesare
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --allow-unauthenticated \
    ca-certificates \
    gnupg2 \
    net-tools \
    dphys-swapfile \
    wget \
    systemd \
    systemd-sysv \
    telnet \
    vim \
    curl \
    nano \
    libcurl3-gnutls \
    libmediainfo0v5 \
    libmms0 \
    libnghttp2-14 \
    librtmp1 \
    libssh2-1 \
    libzen0v5 \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Adaugă cheia publică pentru 3CX PBX
RUN wget -qO- https://repo.3cx.com/key.pub | gpg --dearmor > /usr/share/keyrings/3cx-archive-keyring.gpg

# Adaugă repozitoriile
RUN echo "deb [arch=amd64 by-hash=yes signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] http://repo.3cx.com/3cx $DEBIAN_VERSION main" | tee /etc/apt/sources.list.d/3cxpbx.list \
    && echo "deb http://deb.debian.org/debian/ $DEBIAN_VERSION main"  | tee /etc/apt/sources.list \
    && echo "deb-src http://deb.debian.org/debian/ $DEBIAN_VERSION main"  | tee -a /etc/apt/sources.list

# Actualizează din nou pachetele înainte de instalarea 3CX PBX
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y 3cxpbx

EXPOSE 5015/tcp
EXPOSE 5001/tcp
EXPOSE 5060/tcp
EXPOSE 5060/udp
EXPOSE 5061/tcp
EXPOSE 5090/tcp
EXPOSE 5090/udp
EXPOSE 9000-9500/udp

# Începe systemd
CMD ["/lib/systemd/systemd"]

# Șterge cache-ul apt
RUN rm -rf /var/lib/apt/lists/*
