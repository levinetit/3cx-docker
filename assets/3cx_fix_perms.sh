#!/bin/bash

# Ownership fix for su/sudo
chown root:root /bin/su 2>/dev/null || true
chown root:root /usr/bin/sudo 2>/dev/null || true
chown root:root /usr/lib/sudo/sudoers.so 2>/dev/null || true
chown root:root /etc/sudoers 2>/dev/null || true
chown -R root:root /etc/sudoers.d 2>/dev/null || true
chmod +s /usr/bin/sudo 2>/dev/null || true

# Make postgres able to access its CFGs
chown -R root:postgres /etc/postgresql 2>/dev/null || true
chown -R root:postgres /etc/postgresql-common 2>/dev/null || true

# Recreate fresh postgres db, if does not exist yet and fix perms
chown -R postgres:postgres /var/lib/postgresql 2>/dev/null || true

DBVER=15
DBPATH=/var/lib/postgresql/$DBVER/main
if [ ! -e "$DBPATH" ] && id postgres &>/dev/null; then
    mkdir -p $DBPATH
    chown -R postgres:postgres /var/lib/postgresql
    su -s /bin/bash -c "/usr/lib/postgresql/$DBVER/bin/initdb $DBPATH" postgres 2>/dev/null || true
fi

# Postgres wants to access this private SSL key
chown root:postgres /etc/ssl/private 2>/dev/null || true
chown postgres:postgres /etc/ssl/private/ssl-cert-snakeoil.key 2>/dev/null || true
chmod g-r /etc/ssl/private/ssl-cert-snakeoil.key 2>/dev/null || true
