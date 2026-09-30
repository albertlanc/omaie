#!/bin/bash
install_core_deps() {
    apt update -y
    apt install -y haproxy nginx stunnel4 dropbear squid openvpn sqlite3 curl wget jq uuid-runtime iptables socat cron cmake golang
    sqlite3 "/etc/smartking4luv/database.sqlite" "CREATE TABLE IF NOT EXISTS ssh_users (username TEXT, password TEXT, expiry DATE, quota INTEGER, max_login INTEGER, status TEXT);"
    sqlite3 "/etc/smartking4luv/database.sqlite" "CREATE TABLE IF NOT EXISTS xray_users (username TEXT, uuid TEXT, protocol TEXT, expiry DATE);"
}

install_backend_engines() {
    # Install Xray Core
    echo "[*] Installing Xray..."
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    cat << 'XRAY' > /usr/local/etc/xray/config.json
{
  "inbounds": [
    {"port": 10001, "protocol": "vless", "settings": {"clients": [], "decryption": "none"}, "streamSettings": {"network": "ws", "wsSettings": {"path": "/xray"}}}
  ],
  "outbounds": [{"protocol": "freedom"}]
}
XRAY
    systemctl restart xray

    # Configure Dropbear & Stunnel (SSH Backend)
    echo "[*] Configuring Dropbear & Stunnel..."
    sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
    sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=109/g' /etc/default/dropbear
    cat << 'STUN' > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel.pid
cert = /etc/ssl/smartking.pem
[dropbear]
accept = 444
connect = 127.0.0.1:109
STUN
    sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
    systemctl restart dropbear stunnel4

    # Install SlowDNS (DNSTT)
    echo "[*] Compiling DNSTT (SlowDNS)..."
    wget -qO /usr/local/bin/dnstt-server https://github.com/Yukkiteru/dnstt/releases/latest/download/dnstt-server
    chmod +x /usr/local/bin/dnstt-server
    mkdir -p /etc/slowdns
    /usr/local/bin/dnstt-server -gen > /etc/slowdns/keys.txt
    PUB=$(grep "pubkey" /etc/slowdns/keys.txt | awk '{print $2}')
    echo "$PUB" > /etc/smartking4luv/slowdns_pub
    
    cat << SRV > /etc/systemd/system/client-dnstt.service
[Unit]
Description=DNSTT Server
After=network.target
[Service]
ExecStart=/usr/local/bin/dnstt-server -udp :5300 -privkey-file /etc/slowdns/server.key $(cat /etc/smartking4luv/domain) 127.0.0.1:22
Restart=always
[Install]
WantedBy=multi-user.target
SRV
    systemctl enable client-dnstt; systemctl start client-dnstt
}
