#!/bin/bash
# 3CX Auto Setup - rulat automat la pornirea containerului via systemd
# Pregateste PostgreSQL, utilizatorii, bazele de date si directoarele necesare pentru 3CX

LOG=/var/log/3cx_autosetup.log
mkdir -p "$(dirname "$LOG")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [3cx-autosetup] $*" | tee -a "$LOG"; }

log "=== Inceput setup automat 3CX ==="

# 0. Mascheaza servicii incompatibile cu containerul
systemctl mask dphys-swapfile.service 2>/dev/null || true

# 1. Asigura directorul de log nginx
if [ ! -d /var/log/nginx ]; then
    log "Creare /var/log/nginx..."
    mkdir -p /var/log/nginx
    chown -R www-data:adm /var/log/nginx 2>/dev/null || chown -R www-data:www-data /var/log/nginx 2>/dev/null || true
fi

# 2. Asteapta ca clusterul PostgreSQL principal (main, port 5432) sa fie ready
log "Astept PostgreSQL cluster main (port 5432)..."
for i in $(seq 1 30); do
    if su -s /bin/bash -c "pg_isready -p 5432 -q" postgres 2>/dev/null; then
        log "PostgreSQL main este ready."
        break
    fi
    sleep 2
    if [ "$i" -eq 30 ]; then
        log "EROARE: PostgreSQL main nu a pornit in 60s. Incerc pornirea..."
        pg_ctlcluster 15 main start || true
        sleep 5
    fi
done

# 3. Creeaza clusterul PostgreSQL 3cx pe portul 5480 (daca nu exista)
if [ ! -d /var/lib/postgresql/15/3cx ]; then
    log "Creare cluster PostgreSQL '3cx' pe portul 5480..."
    pg_createcluster 15 3cx --port 5480
    log "Cluster 3cx creat."
fi

# 4. Porneste clusterul 3cx daca nu e running
if ! pg_lsclusters | grep -E "^15\s+3cx\s+.*online" > /dev/null 2>&1; then
    log "Pornire cluster PostgreSQL 3cx..."
    pg_ctlcluster 15 3cx start
    sleep 3
fi

# 5. Fix pg_hba.conf pe ambele clustere - trust pentru phonesystem
for CONF in /etc/postgresql/15/main/pg_hba.conf /etc/postgresql/15/3cx/pg_hba.conf; do
    if [ -f "$CONF" ] && ! grep -q "phonesystem" "$CONF"; then
        log "Adaug reguli trust phonesystem in $CONF..."
        # Adauga inainte de prima linie 'host' existenta
        sed -i '/^# IPv4 local connections:/a host    all             phonesystem     127.0.0.1/32            trust' "$CONF"
        sed -i '/^# IPv6 local connections:/a host    all             phonesystem     ::1\/128                 trust' "$CONF"
    fi
done

# 6. Reload PostgreSQL configs
pg_ctlcluster 15 main reload 2>/dev/null || true
pg_ctlcluster 15 3cx reload 2>/dev/null || true
sleep 1

# 7. Creeaza utilizatorul phonesystem pe clusterul main (5432)
if ! su -s /bin/bash -c "psql -p 5432 -tAc \"SELECT 1 FROM pg_roles WHERE rolname='phonesystem'\"" postgres 2>/dev/null | grep -q 1; then
    log "Creare utilizator 'phonesystem' pe portul 5432..."
    su -s /bin/bash -c "psql -p 5432 -c \"CREATE USER phonesystem WITH PASSWORD 'phonesystem' SUPERUSER;\"" postgres
fi

# 8. Creeaza utilizatorul phonesystem pe clusterul 3cx (5480)
if ! su -s /bin/bash -c "psql -p 5480 -tAc \"SELECT 1 FROM pg_roles WHERE rolname='phonesystem'\"" postgres 2>/dev/null | grep -q 1; then
    log "Creare utilizator 'phonesystem' pe portul 5480..."
    su -s /bin/bash -c "psql -p 5480 -c \"CREATE USER phonesystem WITH PASSWORD 'phonesystem' SUPERUSER;\"" postgres
fi

# 9. Creeaza bazele de date pe clusterul 5480
for DB in masterprofiles database_single; do
    if ! su -s /bin/bash -c "psql -p 5480 -lqt | cut -d'|' -f1 | tr -d ' ' | grep -qx '$DB'" postgres 2>/dev/null; then
        log "Creare baza de date '$DB' pe portul 5480..."
        su -s /bin/bash -c "psql -p 5480 -c \"CREATE DATABASE $DB OWNER phonesystem;\"" postgres
    fi
done

# 10. Enable si porneste 3CXCfgServ01 daca este instalat
if [ -f /lib/systemd/system/3CXCfgServ01.service ]; then
    systemctl enable 3CXCfgServ01.service 2>/dev/null || true
    if ! systemctl is-active --quiet 3CXCfgServ01.service; then
        log "Pornire 3CXCfgServ01.service..."
        systemctl start 3CXCfgServ01.service || true
    fi
fi

log "=== Setup automat 3CX finalizat cu succes ==="
