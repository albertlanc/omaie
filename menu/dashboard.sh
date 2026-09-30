#!/bin/bash
get_status() { systemctl is-active --quiet $1 && echo -e "\033[0;32m[ON]\033[0m" || echo -e "\033[0;31m[OFF]\033[0m"; }
show_dashboard() {
    clear
    UPTIME=$(uptime -p | cut -d " " -f 2-); RAM=$(free -m | awk '/Mem:/ { printf("%3.1f%%", $3/$2*100) }')
    DOMAIN=$(cat /etc/smartking4luv/domain 2>/dev/null || echo "Not Set"); IP=$(curl -sS ipv4.icanhazip.com 2>/dev/null)
    echo -e "\033[0;34m======================================================================\033[0m"
    echo -e "\033[1;36m                      SMARTKING4LUV v2 PRO                            \033[0m"
    echo -e "\033[0;34m======================================================================\033[0m"
    echo -e " \033[1;33mHost:\033[0m $HOSTNAME          \033[1;33mRAM Usage:\033[0m $RAM\n \033[1;33mIP:\033[0m   $IP     \033[1;33mUptime:\033[0m    $UPTIME\n \033[1;33mDomain:\033[0m $DOMAIN"
    echo -e "\033[0;34m----------------------------------------------------------------------\033[0m\n \033[1;33mSERVICES STATUS:\033[0m"
    echo -e " SSH-WS: $(get_status stunnel4)   XRAY: $(get_status nginx)   WG: $(get_status wg-quick@wg0)\n OVPN: $(get_status openvpn)   HAPROXY: $(get_status haproxy)"
    echo -e "\033[0;34m======================================================================\033[0m"
    echo -e " 1. 🔐 SSH & OpenVPN & DNSTT Manager\n 2. 🚀 Xray Manager\n 3. 🛡️ WireGuard Manager\n 4. 🌐 Domain Manager\n 7. 🗑️ Uninstall System\n 0. ❌ Exit"
    echo -e "\033[0;34m======================================================================\033[0m"
}
