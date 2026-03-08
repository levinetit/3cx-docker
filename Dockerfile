FROM debian:bookworm

ARG BUILD_STRING
ARG BUILD_DATE
ARG BUILD_TIME

LABEL build.string=$BUILD_STRING
LABEL build.date=$BUILD_DATE
LABEL build.time=$BUILD_TIME

ENV container=docker
ENV LC_ALL=C
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en
ENV DEBIAN_FRONTEND=noninteractive

# Instalare pachete necesare pentru configurare și instalare
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    systemd \
    systemd-sysv \
    curl \
    ca-certificates \
    jq \
    net-tools \
    gpg \
    dphys-swapfile \
    gettext-base \
    debconf-utils \
    && rm -rf /var/lib/apt/lists/*

# Descărcare și instalare cheie publică 3CX PBX (download separat pentru a evita probleme cu \r\n în pipe)
RUN curl -fsSL https://repo.3cx.com/key.pub | tr -d '\r' | gpg --dearmor -o /usr/share/keyrings/3cx-archive-keyring.gpg

# Adăugare repository 3CX PBX (Debian 12 foloseste deja /etc/apt/sources.list.d/debian.sources)
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] http://repo.3cx.com/3cx bookworm main" | tee /etc/apt/sources.list.d/3cxpbx.list

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Instalare 3cxpbx
#RUN apt-get install -y 3cxpbx
#RUN apt-cache policy 3cxpbx | grep -o '20.*' | grep -o '^\S*'
# Expunere porturi
EXPOSE 5015/tcp 5001/tcp 5060/tcp 5060/udp 5061/tcp 5090/tcp 5090/udp 9000-9500/udp

# Pornirea serviciului systemd
CMD ["/lib/systemd/systemd"]
