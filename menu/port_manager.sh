#!/bin/bash
port_menu() {
  clear; echo -e "\033[0;36m=== 🔌 PORT MANAGER ===\033[0m\nActive Ports:"
  ss -tulpn | awk '{print $5, $7}' | grep -E 'haproxy|stunnel|dropbear|xray|squid|badvpn|wg'
  echo -e "\n1. Change Dropbear Port\n0. Back"
  read -p "Select: " opt
  if [ "$opt" == "1" ]; then read -p "New Port: " p; sed -i "s/DROPBEAR_PORT=.*/DROPBEAR_PORT=$p/g" /etc/default/dropbear; systemctl restart dropbear; echo "Changed to $p"; read -p "Enter..."; fi
}
