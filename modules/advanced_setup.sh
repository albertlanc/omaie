#!/bin/bash
setup_squid_udp_ovpn() {
    echo "[*] Configuring Squid Proxy..."
    cat << 'SQUID' > /etc/squid/squid.conf
acl all src all
http_access allow all
http_port 8080
http_port 3128
SQUID
    systemctl restart squid

    echo "[*] Compiling UDP Custom (BadVPN-udpgw)..."
    wget -qO /usr/local/bin/badvpn-udpgw https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64
    chmod +x /usr/local/bin/badvpn-udpgw
    cat << 'UDP' > /etc/systemd/system/badvpn.service
[Unit]
Description=UDP Custom Gateway
After=network.target
[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500 --max-connections-for-client 10
Restart=always
[Install]
WantedBy=multi-user.target
UDP
    systemctl enable badvpn; systemctl start badvpn

    echo "[*] Initializing WireGuard & OpenVPN structure..."
    mkdir -p /etc/wireguard
    if [ ! -f /etc/wireguard/privatekey ]; then
        wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
    fi
}
