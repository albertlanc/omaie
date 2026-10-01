#!/bin/bash
uninstall_menu() {
  clear; echo -e "\033[1;31m=== 🗑️ UNINSTALL SYSTEM ===\033[0m"
  read -p "Are you absolutely sure? This removes everything. (y/n): " c
  if [ "$c" == "y" ]; then
    systemctl stop haproxy nginx stunnel4 dropbear squid openvpn xray badvpn client-dnstt wg-quick@wg0
    apt-get purge -y haproxy nginx stunnel4 dropbear squid openvpn wireguard sqlite3
    rm -rf /etc/smartking4luv /etc/xray /etc/wireguard /etc/squid /etc/haproxy /usr/local/bin/menu
    echo "Cleanup complete. Bye."; exit 0
  fi
}
