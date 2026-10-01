#!/bin/bash
MAG='\033[1;35m'; GRN='\033[1;32m'; CYN='\033[1;36m'; WHT='\033[1;37m'; NC='\033[0m'
DB="/etc/smartking4luv/database.sqlite"; DOM=$(cat /etc/smartking4luv/domain 2>/dev/null)

openvpn_menu() {
  while true; do
    clear
    echo -e "${MAG}┌─ PROTOCOL MANAGEMENT ───────────────────────────────────┐${NC}"
    echo -e "${MAG}├── OPENVPN PROTOCOL MANAGER ─────────────────────────────┤${NC}"
    echo -e "${MAG}│ ${GRN}[01]${CYN} Create OpenVPN User                                ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[02]${CYN} Create Trial OpenVPN User (24 Hours)               ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[03]${CYN} Delete OpenVPN User                                ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[04]${CYN} Download / View .ovpn Config Link                  ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}\n"
    echo -e "${MAG}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[00]${CYN} Back to Main Menu                                  ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select an option [00-04]: " opt
    case $opt in
      01|1) clear; echo -e "${MAG}┌─ CREATE OPENVPN ACCOUNT ────────────────────────────────┐${NC}"
         read -p " Username: " u; read -p " Password: " p; read -p " Days: " d
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',10,1,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         echo -e " ${GRN}[+] OpenVPN Account Created!${NC}\n ${CYN}Download Client Config: ${WHT}http://$DOM:81/client.ovpn${NC}"; read -p " Press Enter..." ;;
      02|2) clear; echo -e "${MAG}┌─ CREATE OPENVPN TRIAL ──────────────────────────────────┐${NC}"
         u="ovpn_trial_$((RANDOM % 899 + 100))"; p=$((RANDOM % 8999 + 1000)); e=$(date -d "+1 day" +"%Y-%m-%d")
         sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',1,1,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         echo -e " ${GRN}[+] Trial Created: $u (Pass: $p)${NC}\n ${CYN}Config Link: ${WHT}http://$DOM:81/client.ovpn${NC}"; read -p " Press Enter..." ;;
      03|3) clear; echo -e "${MAG}┌─ DELETE OPENVPN USER ───────────────────────────────────┐${NC}"
         read -p " Username to delete: " u; userdel -f "$u" 2>/dev/null; sqlite3 $DB "DELETE FROM ssh_users WHERE username='$u'"; echo " ${GRN}[-] Deleted${NC}"; read -p " Press Enter..." ;;
      04|4) clear; echo -e "${MAG}┌─ OPENVPN DOWNLOAD URL ──────────────────────────────────┐${NC}"
         echo -e " ${WHT}http://$DOM:81/client.ovpn${NC}"
         echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"; read -p " Press Enter..." ;;
      00|0) return ;;
    esac
  done
}
