#!/bin/bash
MAG='\033[1;35m'; GRN='\033[1;32m'; CYN='\033[1;36m'; WHT='\033[1;37m'; NC='\033[0m'
DB="/etc/smartking4luv/database.sqlite"; DOM=$(cat /etc/smartking4luv/domain 2>/dev/null)

ss_menu() {
  while true; do
    clear
    echo -e "${MAG}┌─ PROTOCOL MANAGEMENT ───────────────────────────────────┐${NC}"
    echo -e "${MAG}├── SHADOWSOCKS PROTOCOL MANAGER ─────────────────────────┤${NC}"
    echo -e "${MAG}│ ${GRN}[01]${CYN} Create Shadowsocks User                            ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[02]${CYN} Delete Shadowsocks User                            ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}\n"
    echo -e "${MAG}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[00]${CYN} Back to Main Menu                                  ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select: " opt
    case $opt in
      01|1) clear; read -p " Username: " u; read -p " Days: " d; id=$(uuidgen); e=$(date -d "+$d days" +"%Y-%m-%d")
         sqlite3 $DB "INSERT INTO xray_users VALUES ('$u','$id','ss','$e');"
         echo -e "\n ${GRN}[+] SS Account Created!${NC}\n Link: ss://$(echo -n "aes-128-gcm:$id" | base64 -w 0)@$DOM:10005#$u"; read -p " Press Enter..." ;;
      02|2) clear; read -p " Username: " u; sqlite3 $DB "DELETE FROM xray_users WHERE username='$u'"; echo "Deleted"; read -p " Press Enter..." ;;
      00|0) return ;;
    esac
  done
}
