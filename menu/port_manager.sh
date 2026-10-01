#!/bin/bash
MAG='\033[1;35m'; GRN='\033[1;32m'; CYN='\033[1;36m'; WHT='\033[1;37m'; NC='\033[0m'
port_menu() {
  while true; do
    clear
    UDP_PORT=$(grep -o "127.0.0.1:[0-9]*" /etc/systemd/system/badvpn.service 2>/dev/null | cut -d':' -f2 || echo "7300")
    SSH_PORT=$(grep -oP "(?<=DROPBEAR_PORT=)[0-9]+" /etc/default/dropbear 2>/dev/null || echo "109")

    echo -e "${MAG}┌─ SERVICE & PORT MANAGER ────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[01]${CYN} Change UDP Custom Port     (Current: ${WHT}$UDP_PORT${CYN})        ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[02]${CYN} Change Dropbear SSH Port   (Current: ${WHT}$SSH_PORT${CYN})         ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}\n"
    echo -e "${MAG}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[00]${CYN} Back to Main Menu                                  ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select an option [00-02]: " opt
    case $opt in
      01|1) clear; echo -e "${MAG}┌─ CHANGE UDP CUSTOM PORT ────────────────────────────────┐${NC}"
         read -p " Enter New Port (e.g., 7300): " np
         if [[ "$np" =~ ^[0-9]+$ ]]; then
             sed -i "s/127.0.0.1:[0-9]*/127.0.0.1:$np/g" /etc/systemd/system/badvpn.service
             systemctl daemon-reload; systemctl restart badvpn
             echo -e " ${GRN}[+] UDP Custom port successfully changed to $np and restarted.${NC}"
         else echo -e " ${MAG}[!] Invalid Port.${NC}"; fi
         read -p " Press Enter..." ;;
      02|2) clear; echo -e "${MAG}┌─ CHANGE DROPBEAR PORT ──────────────────────────────────┐${NC}"
         read -p " Enter New Port (e.g., 109): " np
         if [[ "$np" =~ ^[0-9]+$ ]]; then
             sed -i "s/DROPBEAR_PORT=.*/DROPBEAR_PORT=$np/g" /etc/default/dropbear
             systemctl restart dropbear
             echo -e " ${GRN}[+] Dropbear port successfully changed to $np.${NC}"
         fi
         read -p " Press Enter..." ;;
      00|0) return ;;
    esac
  done
}
