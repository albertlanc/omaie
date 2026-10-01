#!/bin/bash
DGN='\033[0;32m'; WHT='\033[1;37m'; RED='\033[1;31m'; NC='\033[0m'
DB="/etc/smartking4luv/database.sqlite"; DOM=$(cat /etc/smartking4luv/domain 2>/dev/null)

openvpn_menu() {
  while true; do
    clear
    echo -e "${DGN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${DGN}│ ${WHT}               OPENVPN PROTOCOL MANAGER                 ${DGN}│${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}[1]${NC} ${WHT}Create OpenVPN User${NC}"
    echo -e "  ${RED}[2]${NC} ${WHT}Create Trial OpenVPN User (24H)${NC}"
    echo -e "  ${RED}[3]${NC} ${WHT}Delete OpenVPN User${NC}"
    echo -e "  ${RED}[4]${NC} ${WHT}Download / View .ovpn Config Link${NC}"
    echo -e "${DGN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${RED}[0]${NC} ${WHT}Back to Main Menu${NC}"
    echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select an option: " opt
    case $opt in
      1) clear; echo -e "${DGN}┌─ CREATE OPENVPN ACCOUNT ────────────────────────────────┐${NC}"
         read -p " Username: " u; read -p " Password: " p; read -p " Days: " d
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',10,1,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         echo -e " ${DGN}[+] Account Created!${NC}\n ${RED}Download Client Config:${NC} ${WHT}http://$DOM:81/client.ovpn${NC}"
         echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"; read -p " Press Enter..." ;;
      2) clear; echo -e "${DGN}┌─ CREATE OPENVPN TRIAL ──────────────────────────────────┐${NC}"
         u="ovpn_trial_$((RANDOM % 899 + 100))"; p=$((RANDOM % 8999 + 1000)); e=$(date -d "+1 day" +"%Y-%m-%d")
         sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',1,1,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         echo -e " ${DGN}[+] Trial Created: $u (Pass: $p)${NC}\n ${RED}Config Link:${NC} ${WHT}http://$DOM:81/client.ovpn${NC}"
         echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"; read -p " Press Enter..." ;;
      3) clear; echo -e "${DGN}┌─ DELETE OPENVPN USER ───────────────────────────────────┐${NC}"
         read -p " Username to delete: " u; userdel -f "$u" 2>/dev/null; sqlite3 $DB "DELETE FROM ssh_users WHERE username='$u'"; echo -e " ${RED}[-] Deleted${NC}"; read -p " Press Enter..." ;;
      4) clear; echo -e "${DGN}┌─ OPENVPN DOWNLOAD URL ──────────────────────────────────┐${NC}"
         echo -e "  ${WHT}http://$DOM:81/client.ovpn${NC}"
         echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"; read -p " Press Enter..." ;;
      0) return ;;
    esac
  done
}
