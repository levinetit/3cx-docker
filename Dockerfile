FROM debian:bookworm

ARG BUILD_STRING
ARG BUILD_DATE
ARG BUILD_TIME

LABEL build.string $BUILD_STRING
LABEL build.date $BUILD_DATE
LABEL build.time $BUILD_TIME

ENV container=docker
ENV LC_ALL=C
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en
ENV DEBIAN_FRONTEND=noninteractive

# Instalare pachete necesare pentru configurare și instalare
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    systemd \
    systemd-sysv \
    apt-transport-https \
    curl \
    jq \
    net-tools \
    gpg \
    dphys-swapfile \
    vim \
    nano \
    telnet \
    gettext-base \
    debconf-utils

# Descărcare și instalare cheie publică 3CX PBX
RUN wget -qO- https://repo.3cx.com/key.pub | gpg --dearmor > /usr/share/keyrings/3cx-archive-keyring.gpg

# Adăugare repository 3CX PBX și actualizare listă de pachete
RUN echo "deb [signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] http://repo.3cx.com/3cx bookworm main" | tee /etc/apt/sources.list.d/3cxpbx.list
RUN echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb http://deb.debian.org/debian-security/ bookworm-security main contrib non-free" >> /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y

# Instalare 3cxpbx
#RUN apt-get install -y 3cxpbx
#RUN apt-cache policy 3cxpbx | grep -o '20.*' | grep -o '^\S*'
# Expunere porturi
EXPOSE 5015/tcp 5001/tcp 5060/tcp 5060/udp 5061/tcp 5090/tcp 5090/udp 9000-9500/udp

# Pornirea serviciului systemd

CMD ["/lib/systemd/systemd"]
