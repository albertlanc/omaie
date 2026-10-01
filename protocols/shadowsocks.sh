#!/bin/bash
DGN='\033[0;32m'; WHT='\033[1;37m'; RED='\033[1;31m'; NC='\033[0m'
DB="/etc/smartking4luv/database.sqlite"; DOM=$(cat /etc/smartking4luv/domain 2>/dev/null)

ss_menu() {
  while true; do
    clear
    echo -e "${DGN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${DGN}│ ${WHT}             SHADOWSOCKS PROTOCOL MANAGER               ${DGN}│${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}[1]${NC} ${WHT}Create Shadowsocks User${NC}"
    echo -e "  ${RED}[2]${NC} ${WHT}Delete Shadowsocks User${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}[0]${NC} ${WHT}Back to Main Menu${NC}"
    echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select option: " opt
    case $opt in
      1) clear; echo -e "${DGN}┌─ CREATE SHADOWSOCKS ACCOUNT ────────────────────────────┐${NC}"
         read -p " Username: " u; read -p " Days: " d; id=$(uuidgen); e=$(date -d "+$d days" +"%Y-%m-%d")
         sqlite3 $DB "INSERT INTO xray_users VALUES ('$u','$id','ss','$e');"
         echo -e " ${DGN}[+] SS Account Created!${NC}\n ${RED}Link:${NC} ${WHT}ss://$(echo -n "aes-128-gcm:$id" | base64 -w 0)@$DOM:10005#$u${NC}"
         echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"; read -p " Press Enter..." ;;
      2) clear; echo -e "${DGN}┌─ DELETE SHADOWSOCKS ACCOUNT ────────────────────────────┐${NC}"
         read -p " Username: " u; sqlite3 $DB "DELETE FROM xray_users WHERE username='$u'"; echo -e " ${RED}[-] Deleted${NC}"; read -p " Press Enter..." ;;
      0) return ;;
    esac
  done
}
