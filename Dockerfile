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
    && echo "deb-src http://deb.debian.org/debian/ $DEBIAN_VERSION main"  | tee /etc/apt/sources.list

# Actualizează din nou pachetele înainte de instalarea 3CX PBX
# RUN apt-get update -y && apt-get upgrade -y \

RUN apt-get install -y 3cxpbx
    
# Instalează 3CX PBX
# RUN apt-get install -qq -y --no-install-recommends 3cxpbx \  

EXPOSE 5015/tcp 5001/tcp 5060/tcp 5060/udp 5061/tcp 5090/tcp 5090/udp 9000-9500/udp

# Începe systemd
CMD ["/lib/systemd/systemd"]
