FROM debian:bookworm

ARG BUILD_STRING
ARG BUILD_DATE
ARG BUILD_TIME

LABEL build.string $BUILD_STRING
LABEL build.date   $BUILD_DATE
LABEL build.time   $BUILD_TIME

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Adăugare repository-uri 3CX PBX și Debian
RUN apt-get update && apt-get install -y wget gnupg2

RUN wget -qO- https://repo.3cx.com/key.pub | gpg --dearmor > /usr/share/keyrings/3cx-archive-keyring.gpg

RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] http://repo.3cx.com/3cx bookworm main" | tee -a /etc/apt/sources.list

# Configurare sources.list pentru Debian Bookworm
RUN echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian/ bookworm main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian-security/ bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian-security/ bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free" >> /etc/apt/sources.list

# Instalare pachete necesare
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    gettext-base \
    gnupg2 \
    gnupg1 \
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
    apt-utils \
    && rm -rf /var/lib/apt/lists/*

# Expunere porturi
EXPOSE 5015/tcp 5001/tcp 5060/tcp 5060/udp 5061/tcp 5090/tcp 5090/udp 9000-9500/udp

# Pornirea serviciului systemd
CMD ["/lib/systemd/systemd"]
