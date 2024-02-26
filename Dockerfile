FROM debian:bookworm

# Instalare pachete necesare
RUN apt-get update && apt-get upgrade -y && apt-get install -y --allow-unauthenticated \
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
    systemd \
    systemd-sysv \
    && rm -rf /var/lib/apt/lists/*
    
# Adăugare repository-uri 3CX PBX și Debian
RUN wget -qO- https://repo.3cx.com/key.pub | gpg --dearmor > /usr/share/keyrings/3cx-archive-keyring.gpg

RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] http://repo.3cx.com/3cx bookworm main" | tee -a /etc/apt/sources.list

RUN echo "deb http://deb.debian.org/debian/ bookworm main" tee -a /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y

EXPOSE 5015/tcp 5001/tcp 5060/tcp 5060/udp 5061/tcp 5090/tcp 5090/udp 9000-9500/udp

# Pornirea serviciului systemd

CMD ["bash"]
