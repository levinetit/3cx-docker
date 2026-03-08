FROM debian:bookworm

ARG PACKAGE_VERSION
ARG DEBIAN_VERSION=bookworm
ARG BUILD_STRING
ARG BUILD_DATE
ARG BUILD_TIME

LABEL build.string=$BUILD_STRING
LABEL build.date=$BUILD_DATE
LABEL build.time=$BUILD_TIME
LABEL version=$PACKAGE_VERSION

ENV container=docker
ENV LC_ALL=C
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en
ENV DEBIAN_FRONTEND=noninteractive

# Instalare pachete de baza (inclusiv sudo, ssl-cert necesare pentru 3CX)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget gnupg systemd systemd-sysv curl ca-certificates \
    jq net-tools gpg dphys-swapfile gettext-base debconf-utils \
    sudo ssl-cert postgresql-common \
    && rm -rf /var/lib/apt/lists/*

# Adaugare repo 3CX
RUN curl -fsSL https://repo.3cx.com/key.pub | tr -d '\r' \
        | gpg --dearmor -o /usr/share/keyrings/3cx-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/3cx-archive-keyring.gpg] \
        http://repo.3cx.com/3cx ${DEBIAN_VERSION} main" \
        | tee /etc/apt/sources.list.d/3cxpbx.list

# Instalare 3cxpbx cu mock systemctl (systemd nu ruleaza in build)
RUN apt-get update && apt-get upgrade -y \
    && printf '#!/bin/sh\nexit 0\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
    && printf '#!/bin/sh\nexit 0\n' > /usr/local/sbin/systemctl && chmod +x /usr/local/sbin/systemctl \
    && ( if [ -n "$PACKAGE_VERSION" ]; then \
            echo 1 | apt-get install -y 3cxpbx=${PACKAGE_VERSION}; \
         else \
            echo 1 | apt-get install -y 3cxpbx; \
         fi ) \
    && rm -f /usr/sbin/policy-rc.d /usr/local/sbin/systemctl \
    && rm -rf /var/lib/apt/lists/*

# Copiere scripturi custom
COPY assets/3cx_fix_perms.sh /3cx_fix_perms.sh
COPY assets/3cx_fix_perms.service /etc/systemd/system/3cx_fix_perms.service
COPY assets/3cx_autosetup.sh /3cx_autosetup.sh
COPY assets/3cx_autosetup.service /etc/systemd/system/3cx_autosetup.service

# Permisiuni + activare servicii via symlink (fara systemctl activ)
RUN chmod +x /3cx_fix_perms.sh /3cx_autosetup.sh \
    && mkdir -p /etc/systemd/system/multi-user.target.wants \
    # Mascare servicii incompatibile cu containerul Docker
    && ln -sf /dev/null /etc/systemd/system/dphys-swapfile.service \
    && ln -sf /dev/null /etc/systemd/system/systemd-logind.service \
    && ln -sf /dev/null /etc/systemd/system/console-getty.service \
    && ln -sf /dev/null /etc/systemd/system/getty.target \
    # Activare servicii necesare
    && ln -sf /lib/systemd/system/nginx.service \
              /etc/systemd/system/multi-user.target.wants/nginx.service \
    && ln -sf /lib/systemd/system/postgresql.service \
              /etc/systemd/system/multi-user.target.wants/postgresql.service \
    && ln -sf /etc/systemd/system/3cx_fix_perms.service \
              /etc/systemd/system/multi-user.target.wants/3cx_fix_perms.service \
    && ln -sf /etc/systemd/system/3cx_autosetup.service \
              /etc/systemd/system/multi-user.target.wants/3cx_autosetup.service \
    && (ln -sf /lib/systemd/system/exim4.service \
               /etc/systemd/system/multi-user.target.wants/exim4.service 2>/dev/null || true)

EXPOSE 5015/tcp 5001/tcp 5060/tcp 5060/udp 5061/tcp 5090/tcp 5090/udp 9000-9500/udp

CMD ["/lib/systemd/systemd"]
