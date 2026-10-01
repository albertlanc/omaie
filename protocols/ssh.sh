#!/bin/bash
DGN='\033[0;32m'; WHT='\033[1;37m'; RED='\033[1;31m'; WHT='\033[1;37m'; NC='\033[0m'
DB="/etc/smartking4luv/database.sqlite"
DOM=$(cat /etc/smartking4luv/domain 2>/dev/null); NS=$(cat /etc/smartking4luv/ns 2>/dev/null); IP=$(curl -sS ipv4.icanhazip.com 2>/dev/null)
PUB=$(cat /etc/smartking4luv/slowdns_pub 2>/dev/null)

print_account() {
    clear
    UDP_PORT=$(grep -o "127.0.0.1:[0-9]*" /etc/systemd/system/badvpn.service 2>/dev/null | cut -d':' -f2 || echo "7300")
    echo -e "${DGN}┌─ ACCOUNT CREATED SUCCESSFULLY ──────────────────────────┐${NC}"
    echo -e " ${WHT}Username    : ${WHT}$1\n ${WHT}Password    : ${WHT}$2\n ${WHT}Expiry      : ${WHT}$3\n ${WHT}Max Login   : ${WHT}$4\n ${WHT}Data Quota  : ${WHT}$5GB\n ${WHT}Server IP   : ${WHT}$IP\n ${WHT}Domain      : ${WHT}$DOM"
    echo -e "${DGN}├─ UDP CUSTOM CONFIGURATION ──────────────────────────────┤${NC}"
    echo -e " ${WHT}UDP Server   : ${WHT}$IP\n ${WHT}UDP Port     : ${WHT}1-65535 (Dynamic)\n ${WHT}UDPGW Port   : ${WHT}$UDP_PORT\n ${WHT}Account User : ${WHT}$1\n ${WHT}Account Pass : ${WHT}$2${NC}"
    echo -e "${DGN}├─ MULTIPLE TESTED PAYLOADS ──────────────────────────────┤${NC}"
    echo -e " ${RED}[01. Cloudflare CDN / WebSocket Payload]${NC}\n ${WHT}GET / HTTP/1.1[crlf]Host: $DOM[crlf]Upgrade: websocket[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf][crlf]${NC}"
    echo -e "\n ${RED}[02. Direct WS / HTTP Custom Payload]${NC}\n ${WHT}GET wss://$DOM/ HTTP/1.1[crlf]Host: $DOM[crlf]Upgrade: websocket[crlf]Connection: Keep-Alive[crlf][crlf]${NC}"
    echo -e "\n ${RED}[03. SlowDNS (DNSTT) Configuration]${NC}\n ${WHT}Domain : $DOM\n NS     : $NS\n PubKey : $PUB${NC}"
    echo -e "\n ${RED}[04. Downloadable OpenVPN Config Link]${NC}\n ${WHT}http://$DOM:81/client.ovpn${NC}"
    echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Press Enter to return..."
}

select_ssh_user() {
    users=($(sqlite3 "$DB" "SELECT username FROM ssh_users;"))
    if [ ${#users[@]} -eq 0 ]; then echo -e " ${DGN}[!] No users found.${NC}"; return 1; fi
    echo -e "${DGN}┌─ REGISTERED SSH ACCOUNTS ───────────────────────────────┐${NC}"
    local i=1
    for u in "${users[@]}"; do
        info=$(sqlite3 "$DB" "SELECT expiry, status FROM ssh_users WHERE username='$u';")
        exp=$(echo "$info" | cut -d'|' -f1); stat=$(echo "$info" | cut -d'|' -f2)
        printf " ${DGN}│${NC} ${WHT}[%02d]${NC} ${WHT}%-16s${NC} Exp: ${RED}%-10s${NC} Stat: %b\n" "$i" "$u" "$exp" "$stat"
        ((i++))
    done
    echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Enter choice [Number or Username]: " target
    if [[ "$target" =~ ^[0-9]+$ ]] && [ "$target" -ge 1 ] && [ "$target" -le ${#users[@]} ]; then SELECTED_USER="${users[$((target-1))]}"; else SELECTED_USER="$target"; fi
}

ssh_menu() {
  while true; do
    clear
    tot=$(sqlite3 $DB "SELECT count(*) FROM ssh_users;" 2>/dev/null || echo 0)
    on=$(netstat -anp 2>/dev/null | grep ESTABLISHED | grep sshd | wc -l); off=$((tot - on)); [ $off -lt 0 ] && off=0
    stat=$(systemctl is-active --quiet stunnel4 && echo -e "${WHT}[ONLINE]${NC}" || echo -e "\033[1;31m[OFFLINE]${NC}")

    echo -e "${DGN}┌─ PROTOCOL MANAGEMENT ───────────────────────────────────┐${NC}"
    echo -e "${DGN}├── SSH & UDP CUSTOM PROTOCOL MANAGER ────────────────────┤${NC}"
    echo -e "${DGN}│ ${WHT}Total Accounts : ${WHT}$tot             ${WHT}Service : ${WHT}$stat${DGN}      │${NC}"
    echo -e "${DGN}│ ${WHT}Online Users   : ${WHT}$on             ${WHT}Offline : ${WHT}$off${DGN}          │${NC}"
    echo -e "${DGN}├── ACCOUNT PROVISIONING ─────────────────────────────────┤${NC}"
    echo -e "${DGN}│ ${WHT}[01]${RED} Create Premium SSH & UDP Custom User               ${DGN}│${NC}"
    echo -e "${DGN}│ ${WHT}[02]${RED} Create Trial SSH & UDP User (24 Hours)             ${DGN}│${NC}"
    echo -e "${DGN}├── ACCOUNT MANAGEMENT ───────────────────────────────────┤${NC}"
    echo -e "${DGN}│ ${WHT}[03]${RED} Renew / Extend SSH User                            ${DGN}│${NC}"
    echo -e "${DGN}│ ${WHT}[04]${RED} Lock SSH User (Disable Login)                      ${DGN}│${NC}"
    echo -e "${DGN}│ ${WHT}[05]${RED} Unlock SSH User (Enable Login)                     ${DGN}│${NC}"
    echo -e "${DGN}│ ${WHT}[06]${RED} Delete SSH User                                    ${DGN}│${NC}"
    echo -e "${DGN}├── MONITORING & DIAGNOSTICS ─────────────────────────────┤${NC}"
    echo -e "${DGN}│ ${WHT}[07]${RED} Live Monitor & Multi-Login Manager                 ${DGN}│${NC}"
    echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}\n"
    echo -e "${DGN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${DGN}│ ${WHT}[00]${RED} Back to Main Menu                                  ${DGN}│${NC}"
    echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select an option [00-07]: " opt
    
    case $opt in
      01|1) clear; echo -e "${DGN}┌─ CREATE PREMIUM ACCOUNT ────────────────────────────────┐${NC}"
         read -p " Username: " u; read -p " Password: " p; read -p " Days: " d; read -p " Max Logins: " m; read -p " Quota (GB): " q
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',$q,$m,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         print_account "$u" "$p" "$e" "$m" "$q" ;;
      02|2) clear; echo -e "${DGN}┌─ GENERATING TRIAL ACCOUNT (24H) ────────────────────────┐${NC}"
         u="trial_$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)"; p=$((RANDOM % 8999 + 1000)); d=1; m=1; q=1
         e=$(date -d "+1 day" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',$q,$m,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         print_account "$u" "$p" "$e" "$m" "$q" ;;
      03|3) clear; echo -e "${DGN}┌─ RENEW SSH ACCOUNT ─────────────────────────────────────┐${NC}"
         select_ssh_user || { read -p " Press Enter..."; continue; }
         read -p " Add Days: " d; e=$(date -d "+$d days" +"%Y-%m-%d"); usermod -e "$e" "$SELECTED_USER" 2>/dev/null
         sqlite3 $DB "UPDATE ssh_users SET expiry='$e' WHERE username='$SELECTED_USER';"
         echo -e " ${WHT}[+] Account $SELECTED_USER renewed to $e${NC}"; read -p " Press Enter..." ;;
      04|4) clear; echo -e "${DGN}┌─ LOCK SSH USER ─────────────────────────────────────────┐${NC}"
         select_ssh_user || { read -p " Press Enter..."; continue; }
         usermod -L "$SELECTED_USER" 2>/dev/null; sqlite3 $DB "UPDATE ssh_users SET status='LOCKED' WHERE username='$SELECTED_USER';"
         echo -e " ${WHT}[+] Account $SELECTED_USER LOCKED.${NC}"; read -p " Press Enter..." ;;
      05|5) clear; echo -e "${DGN}┌─ UNLOCK SSH USER ───────────────────────────────────────┐${NC}"
         select_ssh_user || { read -p " Press Enter..."; continue; }
         usermod -U "$SELECTED_USER" 2>/dev/null; sqlite3 $DB "UPDATE ssh_users SET status='ACTIVE' WHERE username='$SELECTED_USER';"
         echo -e " ${WHT}[+] Account $SELECTED_USER UNLOCKED.${NC}"; read -p " Press Enter..." ;;
      06|6) clear; echo -e "${DGN}┌─ DELETE SSH USER ───────────────────────────────────────┐${NC}"
         select_ssh_user || { read -p " Press Enter..."; continue; }
         userdel -f "$SELECTED_USER" 2>/dev/null; sqlite3 $DB "DELETE FROM ssh_users WHERE username='$SELECTED_USER';"
         echo -e " ${WHT}[-] Account $SELECTED_USER removed.${NC}"; read -p " Press Enter..." ;;
      07|7) clear; echo -e "${DGN}┌─ ACTIVE SSH CONNECTIONS ────────────────────────────────┐${NC}"
         netstat -tnpa 2>/dev/null | grep -E 'sshd|dropbear' | awk '{print $4, $5, $7}' | column -t
         echo -e "${DGN}└─────────────────────────────────────────────────────────┘${NC}"; read -p " Press Enter..." ;;
      00|0) return ;;
    esac
  done
}
