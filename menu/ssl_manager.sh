#!/bin/bash
DGN='\033[0;32m'; WHT='\033[1;37m'; RED='\033[1;31m'; NC='\033[0m'
ssl_menu() {
  while true; do
    clear
    echo -e "${DGN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${DGN}│ ${WHT}                DOMAIN & SSL MANAGER                    ${DGN}│${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}[1]${NC} ${WHT}Change System Domain & Name Server${NC}"
    echo -e "  ${RED}[2]${NC} ${WHT}Renew SSL Certificate (Acme.sh)${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}[0]${NC} ${WHT}Back to Main Menu${NC}"
    echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select option: " opt
    case $opt in
      1) clear; echo -e "${DGN}┌─ CHANGE DOMAIN ─────────────────────────────────────────┐${NC}"
         read -p " New Domain: " d; read -p " New Name Server: " n
         echo "$d" > /etc/smartking4luv/domain; echo "$n" > /etc/smartking4luv/ns
         echo -e " ${DGN}[+] System domain updated.${NC}"; read -p " Press Enter..." ;;
      2) clear; echo -e "${DGN}┌─ RENEW SSL CERTIFICATE ─────────────────────────────────┐${NC}"
         echo -e " ${WHT}Requesting new SSL for $(cat /etc/smartking4luv/domain)...${NC}"
         ~/.acme.sh/acme.sh --issue -d $(cat /etc/smartking4luv/domain) --standalone
         ~/.acme.sh/acme.sh --installcert -d $(cat /etc/smartking4luv/domain) --fullchainpath /etc/ssl/smartking.pem --keypath /etc/ssl/smartking.key
         systemctl restart stunnel4 haproxy
         echo -e " ${DGN}[+] SSL Renewed and services restarted.${NC}"; read -p " Press Enter..." ;;
      0) return ;;
    esac
  done
}
