#!/bin/bash
MAG='\033[1;35m'; GRN='\033[1;32m'; CYN='\033[1;36m'; WHT='\033[1;37m'; NC='\033[0m'
DB="/etc/smartking4luv/database.sqlite"
DOM=$(cat /etc/smartking4luv/domain 2>/dev/null); NS=$(cat /etc/smartking4luv/ns 2>/dev/null); IP=$(curl -sS ipv4.icanhazip.com 2>/dev/null)
PUB=$(cat /etc/smartking4luv/slowdns_pub 2>/dev/null)

print_account() {
    clear
    echo -e "${MAG}┌─ ACCOUNT CREATED SUCCESSFULLY ──────────────────────────┐${NC}"
    echo -e " ${GRN}Username    : ${WHT}$1\n ${GRN}Password    : ${WHT}$2\n ${GRN}Expiry      : ${WHT}$3\n ${GRN}Max Login   : ${WHT}$4\n ${GRN}Data Quota  : ${WHT}$5GB\n ${GRN}Server IP   : ${WHT}$IP\n ${GRN}Domain      : ${WHT}$DOM\n ${GRN}Name Server : ${WHT}$NS"
    echo -e "${MAG}├─ SUPPORTED PORTS ───────────────────────────────────────┤${NC}"
    echo -e " ${GRN}- SSH-WS (TLS)      : ${WHT}443\n ${GRN}- SSH-WS (Non-TLS)  : ${WHT}80\n ${GRN}- SSL/Stunnel       : ${WHT}444\n ${GRN}- Dropbear          : ${WHT}109\n ${GRN}- OpenVPN           : ${WHT}1194 (UDP), 442 (TCP)\n ${GRN}- SlowDNS (DNSTT)   : ${WHT}53\n ${GRN}- Squid Proxy       : ${WHT}8080, 3128\n ${GRN}- BadVPN (UDPGW)    : ${WHT}7300"
    echo -e "${MAG}├─ MULTIPLE TESTED PAYLOADS ──────────────────────────────┤${NC}"
    echo -e " ${CYN}[01. Cloudflare CDN / WebSocket Payload]${NC}"
    echo -e " ${WHT}GET / HTTP/1.1[crlf]Host: $DOM[crlf]Upgrade: websocket[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf][crlf]${NC}"
    echo -e "\n ${CYN}[02. Direct WS / HTTP Custom Payload]${NC}"
    echo -e " ${WHT}GET wss://$DOM/ HTTP/1.1[crlf]Host: $DOM[crlf]Upgrade: websocket[crlf]Connection: Keep-Alive[crlf][crlf]${NC}"
    echo -e "\n ${CYN}[03. Split Fronting / HTTP Injector Payload]${NC}"
    echo -e " ${WHT}GET / HTTP/1.1[crlf]Host: $DOM[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf][crlf]CONNECT [host_port] HTTP/1.1[crlf][crlf]${NC}"
    echo -e "\n ${CYN}[04. SlowDNS (DNSTT) Configuration]${NC}"
    echo -e " ${WHT}Domain : $DOM\n NS     : $NS\n PubKey : $PUB${NC}"
    echo -e "\n ${CYN}[05. Downloadable OpenVPN Config Link]${NC}"
    echo -e " ${WHT}http://$DOM:81/client.ovpn${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Press Enter to return..."
}

select_ssh_user() {
    users=($(sqlite3 "$DB" "SELECT username FROM ssh_users;"))
    if [ ${#users[@]} -eq 0 ]; then
        echo -e " ${MAG}[!] No users found in database.${NC}"
        return 1
    fi
    echo -e "${MAG}┌─ REGISTERED SSH ACCOUNTS ────────────────────────────────┐${NC}"
    local i=1
    for u in "${users[@]}"; do
        info=$(sqlite3 "$DB" "SELECT expiry, status FROM ssh_users WHERE username='$u';")
        exp=$(echo "$info" | cut -d'|' -f1)
        stat=$(echo "$info" | cut -d'|' -f2)
        printf " ${MAG}│${NC} ${GRN}[%02d]${NC} ${WHT}%-16s${NC} Exp: ${CYN}%-10s${NC} Status: %b\n" "$i" "$u" "$exp" "$stat"
        ((i++))
    done
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Enter choice [Number or Username]: " target
    if [[ "$target" =~ ^[0-9]+$ ]] && [ "$target" -ge 1 ] && [ "$target" -le ${#users[@]} ]; then
        SELECTED_USER="${users[$((target-1))]}"
    else
        SELECTED_USER="$target"
    fi
}

ssh_menu() {
  while true; do
    clear
    tot=$(sqlite3 $DB "SELECT count(*) FROM ssh_users;" 2>/dev/null || echo 0)
    on=$(netstat -anp 2>/dev/null | grep ESTABLISHED | grep sshd | wc -l)
    off=$((tot - on))
    [ $off -lt 0 ] && off=0
    stat=$(systemctl is-active --quiet stunnel4 && echo -e "${GRN}[ONLINE]${NC}" || echo -e "\033[1;31m[OFFLINE]${NC}")

    echo -e "${MAG}┌─ PROTOCOL MANAGEMENT ───────────────────────────────────┐${NC}"
    echo -e "${MAG}├── SSH, SSHWS & UDP CUSTOM MANAGER ──────────────────────┤${NC}"
    echo -e "${MAG}│ ${GRN}Total Accounts : ${WHT}$tot             ${GRN}Service : ${WHT}$stat${NC}"
    echo -e "${MAG}│ ${GRN}Online Users   : ${WHT}$on             ${GRN}Offline Users : ${WHT}$off${NC}"
    echo -e "${MAG}├── ACCOUNT PROVISIONING ─────────────────────────────────┤${NC}"
    echo -e "${MAG}│ ${GRN}[01]${CYN} Create Premium SSH User                            ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[02]${CYN} Create Trial SSH User (24 Hours)                   ${MAG}│${NC}"
    echo -e "${MAG}├── ACCOUNT MANAGEMENT ───────────────────────────────────┤${NC}"
    echo -e "${MAG}│ ${GRN}[03]${CYN} Renew / Extend SSH User                            ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[04]${CYN} Lock SSH User (Disable Login)                      ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[05]${CYN} Unlock SSH User (Enable Login)                     ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[06]${CYN} Delete SSH User                                    ${MAG}│${NC}"
    echo -e "${MAG}├── MONITORING & DIAGNOSTICS ─────────────────────────────┤${NC}"
    echo -e "${MAG}│ ${GRN}[07]${CYN} Live Monitor & Multi-Login Manager                 ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}\n"
    echo -e "${MAG}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[00]${CYN} Back to Main Menu                                  ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select an option [00-07]: " opt
    
    case $opt in
      01|1) clear; echo -e "${MAG}┌─ CREATE PREMIUM SSH USER ───────────────────────────────┐${NC}"
         read -p " Username: " u; read -p " Password: " p; read -p " Duration (Days): " d; read -p " Max Logins: " m; read -p " Data Quota (GB): " q
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',$q,$m,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         print_account "$u" "$p" "$e" "$m" "$q" ;;
      02|2) clear; echo -e "${MAG}┌─ GENERATING TRIAL ACCOUNT (24H) ────────────────────────┐${NC}"
         u="trial_$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)"; p=$((RANDOM % 8999 + 1000)); d=1; m=1; q=1
         e=$(date -d "+1 day" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',$q,$m,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         print_account "$u" "$p" "$e" "$m" "$q" ;;
      03|3) clear; echo -e "${MAG}┌─ RENEW SSH ACCOUNT ─────────────────────────────────────┐${NC}"
         select_ssh_user || { read -p " Press Enter..."; continue; }
         read -p " Add Days to $SELECTED_USER: " d
         e=$(date -d "+$d days" +"%Y-%m-%d"); usermod -e "$e" "$SELECTED_USER" 2>/dev/null
         sqlite3 $DB "UPDATE ssh_users SET expiry='$e' WHERE username='$SELECTED_USER';"
         echo -e " ${GRN}[+] Account $SELECTED_USER renewed until $e${NC}"; read -p " Press Enter..." ;;
      04|4) clear; echo -e "${MAG}┌─ LOCK SSH USER ─────────────────────────────────────────┐${NC}"
         select_ssh_user || { read -p " Press Enter..."; continue; }
         usermod -L "$SELECTED_USER" 2>/dev/null
         sqlite3 $DB "UPDATE ssh_users SET status='LOCKED' WHERE username='$SELECTED_USER';"
         echo -e " ${GRN}[+] Account $SELECTED_USER is now LOCKED.${NC}"; read -p " Press Enter..." ;;
      05|5) clear; echo -e "${MAG}┌─ UNLOCK SSH USER ───────────────────────────────────────┐${NC}"
         select_ssh_user || { read -p " Press Enter..."; continue; }
         usermod -U "$SELECTED_USER" 2>/dev/null
         sqlite3 $DB "UPDATE ssh_users SET status='ACTIVE' WHERE username='$SELECTED_USER';"
         echo -e " ${GRN}[+] Account $SELECTED_USER is now UNLOCKED.${NC}"; read -p " Press Enter..." ;;
      06|6) clear; echo -e "${MAG}┌─ DELETE SSH USER ───────────────────────────────────────┐${NC}"
         select_ssh_user || { read -p " Press Enter..."; continue; }
         userdel -f "$SELECTED_USER" 2>/dev/null
         sqlite3 $DB "DELETE FROM ssh_users WHERE username='$SELECTED_USER';"
         echo -e " ${GRN}[-] Account $SELECTED_USER removed from system and DB.${NC}"; read -p " Press Enter..." ;;
      07|7) clear; echo -e "${MAG}┌─ ACTIVE SSH CONNECTIONS ────────────────────────────────┐${NC}"
         netstat -tnpa 2>/dev/null | grep -E 'sshd|dropbear' | awk '{print $4, $5, $7}' | column -t
         echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"; read -p " Press Enter..." ;;
      00|0) return ;;
    esac
  done
}
