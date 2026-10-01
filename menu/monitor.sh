#!/bin/bash
DGN='\033[0;32m'; WHT='\033[1;37m'; RED='\033[1;31m'; NC='\033[0m'
monitor_menu() {
  while true; do
    clear
    CPU=$(top -bn1 | grep load | awk '{printf "%.2f", $(NF-2)}')
    RAM=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)", $3,$2,$3*100/$2 }')
    DISK=$(df -h / | awk '$NF=="/"{printf "%s/%s (%s)", $3,$2,$5}')
    UPTIME=$(uptime -p | cut -d " " -f 2-)
    
    # Network Traffic (Auto-detect interface)
    IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    RX_BYTES=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
    TX_BYTES=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
    RX_MB=$((RX_BYTES / 1048576))
    TX_MB=$((TX_BYTES / 1048576))

    # Active Connections
    SSH_CON=$(netstat -tnpa 2>/dev/null | grep -E 'sshd|dropbear' | grep ESTABLISHED | wc -l)
    XRAY_CON=$(netstat -tnpa 2>/dev/null | grep xray | grep ESTABLISHED | wc -l)
    OVPN_CON=$(netstat -tnpa 2>/dev/null | grep openvpn | grep ESTABLISHED | wc -l)
    WG_CON=$(wg show 2>/dev/null | grep endpoint | wc -l)

    echo -e "${DGN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${DGN}│ ${WHT}           SYSTEM MONITORING & DIAGNOSTICS              ${DGN}│${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}■${NC} ${WHT}CPU Load       ${DGN}:${NC} ${WHT}$CPU${NC}"
    echo -e "  ${RED}■${NC} ${WHT}Memory Usage   ${DGN}:${NC} ${WHT}$RAM${NC}"
    echo -e "  ${RED}■${NC} ${WHT}Disk Usage     ${DGN}:${NC} ${WHT}$DISK${NC}"
    echo -e "  ${RED}■${NC} ${WHT}System Uptime  ${DGN}:${NC} ${WHT}$UPTIME${NC}"
    echo -e "${DGN}├─ NETWORK TRAFFIC ($IFACE) ───────────────────────────────┤${NC}"
    echo -e "  ${RED}▼${NC} ${WHT}Total Received ${DGN}:${NC} ${WHT}${RX_MB} MB${NC}"
    echo -e "  ${RED}▲${NC} ${WHT}Total Transmit ${DGN}:${NC} ${WHT}${TX_MB} MB${NC}"
    echo -e "${DGN}├─ ACTIVE CONNECTIONS ────────────────────────────────────┤${NC}"
    echo -e "  ${WHT}SSH / Dropbear : ${DGN}$SSH_CON${NC}"
    echo -e "  ${WHT}Xray (All)     : ${DGN}$XRAY_CON${NC}"
    echo -e "  ${WHT}OpenVPN        : ${DGN}$OVPN_CON${NC}"
    echo -e "  ${WHT}WireGuard      : ${DGN}$WG_CON${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}[1]${NC} ${WHT}Refresh Stats${NC}"
    echo -e "  ${RED}[0]${NC} ${WHT}Back to Main Menu${NC}"
    echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select option: " opt
    case $opt in
      1) continue ;;
      0) return ;;
    esac
  done
}
