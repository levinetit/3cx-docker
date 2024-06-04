FROM debian:stretch

# Argumentele pentru etichetele de construire
ARG BUILD_STRING
ARG BUILD_DATE
ARG BUILD_TIME

# Etichetele de construire
LABEL build.string="$BUILD_STRING"
LABEL build.date="$BUILD_DATE"
LABEL build.time="$BUILD_TIME"

# Setările de mediu
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en
ENV container=docker

# Actualizarea și instalarea pachetelor necesare
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        wget \
        gnupg2 \
        systemd \
        locales \
        net-tools && \
        
# Descărcarea și adăugarea cheii publice pentru depozitul 3CX PBX
    wget -O- http://downloads.3cx.com/downloads/3cxpbx/public.key | apt-key add - && \
    echo "deb http://downloads.3cx.com/downloads/debian stretch main" | tee /etc/apt/sources.list.d/3cxpbx.list && \
    apt-get update -y && \

# Instalarea 3CX PBX
    apt-get install -y --no-install-recommends \
        3cxpbx && \

# Curățarea cache-ului și a fișierelor temporare
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expunerea porturilor
EXPOSE 5015/tcp 5001/tcp 5060/tcp 5060/udp 5061/tcp 5090/tcp 5090/udp 9000-9500/udp

# Comanda implicită la pornirea containerului
CMD ["/lib/systemd/systemd"]
