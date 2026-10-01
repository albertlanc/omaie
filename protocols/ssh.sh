#!/bin/bash
MAG='\033[1;35m'; GRN='\033[1;32m'; CYN='\033[1;36m'; WHT='\033[1;37m'; NC='\033[0m'
DB="/etc/smartking4luv/database.sqlite"
DOM=$(cat /etc/smartking4luv/domain 2>/dev/null); NS=$(cat /etc/smartking4luv/ns 2>/dev/null); IP=$(curl -sS ipv4.icanhazip.com 2>/dev/null)
PUB=$(cat /etc/smartking4luv/slowdns_pub 2>/dev/null)

ssh_menu() {
  while true; do
    clear
    tot=$(sqlite3 $DB "SELECT count(*) FROM ssh_users;")
    on=$(netstat -anp 2>/dev/null | grep ESTABLISHED | grep sshd | wc -l)
    off=$((tot - on))
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
         read -p " Username: " u; read -p " Password: " p; read -p " Days: " d; read -p " Max Logins: " m; read -p " Quota (GB): " q
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',$q,$m,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         clear; echo -e "${MAG}┌─ ACCOUNT CREATED SUCCESSFULLY ──────────────────────────┐${NC}"
         echo -e " ${GRN}Username    : ${WHT}$u\n ${GRN}Password    : ${WHT}$p\n ${GRN}Expiry      : ${WHT}$e\n ${GRN}Max Login   : ${WHT}$m\n ${GRN}Data Quota  : ${WHT}${q}GB\n ${GRN}Server IP   : ${WHT}$IP\n ${GRN}Domain      : ${WHT}$DOM\n ${GRN}Name Server : ${WHT}$NS"
         echo -e "${MAG}├─ SUPPORTED PORTS ───────────────────────────────────────┤${NC}"
         echo -e " ${GRN}- SSH-WS (TLS)      : ${WHT}443\n ${GRN}- SSH-WS (Non-TLS)  : ${WHT}80\n ${GRN}- SSL/Stunnel       : ${WHT}444\n ${GRN}- Dropbear          : ${WHT}109\n ${GRN}- OpenVPN           : ${WHT}1194 (UDP), 442 (TCP)\n ${GRN}- SlowDNS (DNSTT)   : ${WHT}53\n ${GRN}- Squid Proxy       : ${WHT}8080, 3128\n ${GRN}- BadVPN (UDPGW)    : ${WHT}7300"
         echo -e "${MAG}├─ PAYLOADS & CONFIGS ────────────────────────────────────┤${NC}"
         echo -e " ${CYN}[WS/WSS HTTP Custom Payload]${NC}\n ${WHT}GET wss://$DOM/ HTTP/1.1[crlf]Host: $DOM[crlf]Upgrade: websocket[crlf]Connection: Keep-Alive[crlf][crlf]${NC}"
         echo -e "\n ${CYN}[SlowDNS Config]${NC}\n ${WHT}Domain : $DOM\n NS     : $NS\n PubKey : $PUB${NC}"
         echo -e "\n ${CYN}[OpenVPN Config Link]${NC}\n ${WHT}http://$DOM:81/client.ovpn${NC}"
         echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"; read -p " Press Enter..." ;;
      02|2) clear; echo -e "${MAG}┌─ GENERATING TRIAL ACCOUNT ──────────────────────────────┐${NC}"
         u="trial_$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)"; p=$((RANDOM % 9999 + 1000)); d=1; m=1; q=1
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',$q,$m,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         echo -e " ${GRN}[+] Trial Account $u created. Expires: $e${NC}"; read -p " Press Enter..." ;;
      03|3) clear; echo -e "${MAG}┌─ RENEW SSH ACCOUNT ─────────────────────────────────────┐${NC}\n Active Users:"
         sqlite3 $DB "SELECT username, expiry FROM ssh_users;" | column -t -s '|'
         read -p " Username: " u; read -p " Add Days: " d; e=$(date -d "+$d days" +"%Y-%m-%d"); usermod -e "$e" "$u" 2>/dev/null
         sqlite3 $DB "UPDATE ssh_users SET expiry='$e' WHERE username='$u'"; echo -e " ${GRN}[+] Renewed to $e${NC}"; read -p " Enter..." ;;
      04|4) clear; echo -e "${MAG}┌─ LOCK SSH ACCOUNT ──────────────────────────────────────┐${NC}"
         read -p " Username: " u; usermod -L "$u" 2>/dev/null; sqlite3 $DB "UPDATE ssh_users SET status='LOCKED' WHERE username='$u'"; echo -e " ${GRN}[+] Locked${NC}"; read -p " Enter..." ;;
      05|5) clear; echo -e "${MAG}┌─ UNLOCK SSH ACCOUNT ────────────────────────────────────┐${NC}"
         read -p " Username: " u; usermod -U "$u" 2>/dev/null; sqlite3 $DB "UPDATE ssh_users SET status='ACTIVE' WHERE username='$u'"; echo -e " ${GRN}[+] Unlocked${NC}"; read -p " Enter..." ;;
      06|6) clear; echo -e "${MAG}┌─ DELETE SSH ACCOUNT ────────────────────────────────────┐${NC}"
         read -p " Username: " u; userdel -f "$u" 2>/dev/null; sqlite3 $DB "DELETE FROM ssh_users WHERE username='$u'"; echo -e " ${GRN}[-] Deleted${NC}"; read -p " Enter..." ;;
      07|7) clear; echo -e "${MAG}┌─ LIVE MONITOR ──────────────────────────────────────────┐${NC}"
         netstat -anp 2>/dev/null | grep ESTABLISHED | grep sshd | head -n 15; read -p " Enter..." ;;
      00|0) return ;;
    esac
  done
}
