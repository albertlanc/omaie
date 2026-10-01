#!/bin/bash
CYN='\033[1;36m'; YEL='\033[1;33m'; WHT='\033[1;37m'; BLU='\033[1;34m'; GRN='\033[1;32m'; NC='\033[0m'
DB="/etc/smartking4luv/database.sqlite"; DOM=$(cat /etc/smartking4luv/domain 2>/dev/null)

openvpn_menu() {
  while true; do
    clear
    echo -e "${CYN}╔═════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYN}║ ${WHT}               OPENVPN PROTOCOL MANAGER                 ${CYN}║${NC}"
    echo -e "${CYN}╠═════════════════════════════════════════════════════════╣${NC}"
    echo -e " ${YEL}[01]${WHT} Create OpenVPN User"
    echo -e " ${YEL}[02]${WHT} Create Trial OpenVPN User (24 Hours)"
    echo -e " ${YEL}[03]${WHT} Delete OpenVPN User"
    echo -e " ${YEL}[04]${WHT} Download / View .ovpn Config Link"
    echo -e "${CYN}╠═════════════════════════════════════════════════════════╣${NC}"
    echo -e " ${YEL}[00]${WHT} Back to Main Menu"
    echo -e "${CYN}╚═════════════════════════════════════════════════════════╝${NC}"
    read -p " Select an option [00-04]: " opt
    case $opt in
      01|1) clear; echo -e "${BLU}╭─ CREATE OPENVPN ACCOUNT ────────────────────────────────╮${NC}"
         read -p " Username: " u; read -p " Password: " p; read -p " Days: " d
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',10,1,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         echo -e "${BLU}╰─────────────────────────────────────────────────────────╯${NC}"
         echo -e "\n ${GRN}[+] OpenVPN Account Created!${NC}\n ${CYN}Download Client Config: ${WHT}http://$DOM:81/client.ovpn${NC}"; read -p " Press Enter..." ;;
      04|4) clear; echo -e "${BLU}╭─ OPENVPN DOWNLOAD URL ──────────────────────────────────╮${NC}"
         echo -e " ${WHT}http://$DOM:81/client.ovpn${NC}"
         echo -e "${BLU}╰─────────────────────────────────────────────────────────╯${NC}"; read -p " Press Enter..." ;;
      00|0) return ;;
      *) echo " WIP"; sleep 1;;
    esac
  done
}
