#!/bin/bash
wg_menu() {
  while true; do
    clear; echo -e "\033[0;36m=== 🛡️ WIREGUARD MANAGER ===\033[0m\n1. Create Client\n2. View Existing Clients\n0. Back"
    read -p "Select: " opt
    case $opt in
      1) read -p "Client Name: " u; ip="10.66.66.$(($RANDOM % 200 + 2))"; p=$(wg genkey); pub=$(echo "$p" | wg pubkey); dom=$(cat /etc/smartking4luv/domain)
         echo -e "\n[Peer]\nPublicKey = $pub\nAllowedIPs = $ip/32" >> /etc/wireguard/wg0.conf; systemctl restart wg-quick@wg0
         clear; echo -e "\033[1;32m=== WG CLIENT CONFIG ===\033[0m\n[Interface]\nPrivateKey = $p\nAddress = $ip/32\nDNS = 8.8.8.8\n\n[Peer]\nPublicKey = $(cat /etc/wireguard/publickey)\nEndpoint = $dom:51820\nAllowedIPs = 0.0.0.0/0"
         echo "$u : $ip" >> /etc/wireguard/clients.txt; read -p "Enter..." ;;
      2) clear; echo "Active Clients:"; cat /etc/wireguard/clients.txt 2>/dev/null; read -p "Enter..." ;;
      0) return ;;
    esac
  done
}
