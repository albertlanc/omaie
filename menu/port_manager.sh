#!/bin/bash
DGN='\033[0;32m'; WHT='\033[1;37m'; RED='\033[1;31m'; NC='\033[0m'

change_port() {
    local service=$1
    local file=$2
    local search_pattern=$3
    local restart_cmd=$4
    
    read -p " Enter New Port for $service: " np
    if ! [[ "$np" =~ ^[0-9]+$ ]] || [ "$np" -gt 65535 ]; then
        echo -e " ${RED}[!] Invalid Port Number.${NC}"; read -p " Press Enter..."; return
    fi
    if netstat -tuln | grep -q ":$np "; then
        echo -e " ${RED}[!] CONFLICT: Port $np is already in use by another service!${NC}"
        read -p " Press Enter..."; return
    fi
    
    sed -i "s/$search_pattern/$np/g" "$file"
    eval "$restart_cmd"
    echo -e " ${DGN}[+] $service port successfully changed to $np.${NC}"
    read -p " Press Enter..."
}

port_menu() {
  while true; do
    clear
    # Fetch live ports directly from configs
    P_DROP=$(grep -oP "(?<=DROPBEAR_PORT=)[0-9]+" /etc/default/dropbear 2>/dev/null || echo "109")
    P_UDP=$(grep -o "127.0.0.1:[0-9]*" /etc/systemd/system/badvpn.service 2>/dev/null | cut -d':' -f2 || echo "7300")
    P_STUN=$(grep -oP "(?<=accept = )[0-9]+" /etc/stunnel/stunnel.conf 2>/dev/null || echo "444")
    P_SQUID=$(grep -oP "(?<=http_port )[0-9]+" /etc/squid/squid.conf 2>/dev/null | tr '\n' ',' | sed 's/,$//')

    echo -e "${DGN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${DGN}│ ${WHT}           SYSTEM PORT & PROTOCOL DASHBOARD             ${DGN}│${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}■${NC} ${WHT}OpenSSH             ${DGN}:${NC} ${WHT}22${NC}"
    echo -e "  ${RED}■${NC} ${WHT}Dropbear SSH        ${DGN}:${NC} ${WHT}$P_DROP${NC}"
    echo -e "  ${RED}■${NC} ${WHT}Stunnel4 (SSL)      ${DGN}:${NC} ${WHT}$P_STUN${NC}"
    echo -e "  ${RED}■${NC} ${WHT}Squid Proxy         ${DGN}:${NC} ${WHT}$P_SQUID${NC}"
    echo -e "  ${RED}■${NC} ${WHT}UDP Custom (UDPGW)  ${DGN}:${NC} ${WHT}$P_UDP${NC}"
    echo -e "  ${RED}■${NC} ${WHT}SlowDNS (DNSTT)     ${DGN}:${NC} ${WHT}5300 (UDP) -> 53${NC}"
    echo -e "  ${RED}■${NC} ${WHT}HAProxy Multiplexer ${DGN}:${NC} ${WHT}80, 443${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}[1]${NC} ${WHT}Change Dropbear Port${NC}"
    echo -e "  ${RED}[2]${NC} ${WHT}Change Stunnel4 Port${NC}"
    echo -e "  ${RED}[3]${NC} ${WHT}Change UDP Custom Gateway Port${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}[0]${NC} ${WHT}Back to Main Menu${NC}"
    echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select option: " opt
    
    case $opt in
      1) change_port "Dropbear" "/etc/default/dropbear" "DROPBEAR_PORT=[0-9]*" "DROPBEAR_PORT=" "systemctl restart dropbear" ;;
      2) change_port "Stunnel4" "/etc/stunnel/stunnel.conf" "accept = [0-9]*" "accept = " "systemctl restart stunnel4" ;;
      3) change_port "UDP Custom" "/etc/systemd/system/badvpn.service" "127.0.0.1:[0-9]*" "127.0.0.1:" "systemctl daemon-reload; systemctl restart badvpn" ;;
      0) return ;;
    esac
  done
}
