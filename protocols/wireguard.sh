#!/bin/bash
MAG='\033[1;35m'; GRN='\033[1;32m'; CYN='\033[1;36m'; WHT='\033[1;37m'; NC='\033[0m'
wg_menu() {
  while true; do
    clear
    echo -e "${MAG}┌─ PROTOCOL MANAGEMENT ───────────────────────────────────┐${NC}"
    echo -e "${MAG}├── WIREGUARD PROTOCOL MANAGER ───────────────────────────┤${NC}"
    echo -e "${MAG}│ ${GRN}[01]${CYN} Create WireGuard Client                            ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[02]${CYN} View Active Clients                                ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}\n"
    echo -e "${MAG}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[00]${CYN} Back to Main Menu                                  ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select: " opt
    case $opt in
      01|1) clear; read -p " Client Name: " u; ip="10.66.66.$(($RANDOM % 200 + 2))"; p=$(wg genkey); pub=$(echo "$p" | wg pubkey); dom=$(cat /etc/smartking4luv/domain)
         echo -e "\n[Peer]\nPublicKey = $pub\nAllowedIPs = $ip/32" >> /etc/wireguard/wg0.conf; systemctl restart wg-quick@wg0
         echo "$u | $ip" >> /etc/wireguard/clients.txt
         clear; echo -e "${MAG}┌─ WIREGUARD CLIENT CONFIG ───────────────────────────────┐${NC}"
         echo -e "[Interface]\nPrivateKey = $p\nAddress = $ip/32\nDNS = 8.8.8.8\n\n[Peer]\nPublicKey = $(cat /etc/wireguard/publickey 2>/dev/null)\nEndpoint = $dom:51820\nAllowedIPs = 0.0.0.0/0"
         echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"; read -p " Press Enter..." ;;
      02|2) clear; echo -e "${MAG}Active WireGuard Clients:${NC}\n"; cat /etc/wireguard/clients.txt 2>/dev/null; read -p " Press Enter..." ;;
      00|0) return ;;
    esac
  done
}
