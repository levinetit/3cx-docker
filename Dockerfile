FROM debian:buster

# Pachete necesare
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --allow-unauthenticated \
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
    libtinyxml2-6a \
    libzen0v5 \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Adaugă cheia publică pentru 3CX PBX
RUN wget -O- http://downloads.3cx.com/downloads/3cxpbx/public.key | apt-key add -

# Adaugă repozitoriile
RUN echo "deb http://downloads-global.3cx.com/downloads/debian buster main" | tee /etc/apt/sources.list.d/3cxpbx.list \
    && echo "deb http://deb.debian.org/debian/ bullseye main" >> /etc/apt/sources.list \
    && echo "deb-src http://deb.debian.org/debian/ bullseye main" >> /etc/apt/sources.list

# Actualizează din nou pachetele înainte de instalarea 3CX PBX
RUN apt-get update -y && apt-get upgrade -y

# Instalează 3CX PBX
RUN apt-get install -y 3cxpbx

EXPOSE 5015/tcp 5001/tcp 5060/tcp 5060/udp 5061/tcp 5090/tcp 5090/udp 9000-9500/udp

# Începe systemd
CMD ["/lib/systemd/systemd"]
