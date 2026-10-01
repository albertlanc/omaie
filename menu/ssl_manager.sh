#!/bin/bash
ssl_menu() {
  clear; echo -e "\033[0;36m=== 🌐 DOMAIN & SSL MANAGER ===\033[0m\n1. Change Domain/NS\n2. Renew SSL (Acme.sh)\n0. Back"
  read -p "Select: " opt
  if [ "$opt" == "1" ]; then read -p "New Domain: " d; read -p "New NS: " n; echo "$d" > /etc/smartking4luv/domain; echo "$n" > /etc/smartking4luv/ns; echo "Updated."; read -p "Enter..."; fi
  if [ "$opt" == "2" ]; then ~/.acme.sh/acme.sh --issue -d $(cat /etc/smartking4luv/domain) --standalone; ~/.acme.sh/acme.sh --installcert -d $(cat /etc/smartking4luv/domain) --fullchainpath /etc/ssl/smartking.pem --keypath /etc/ssl/smartking.key; systemctl restart stunnel4 haproxy; echo "Renewed."; read -p "Enter..."; fi
}
