#!/bin/bash
MAG='\033[1;35m'; GRN='\033[1;32m'; CYN='\033[1;36m'; WHT='\033[1;37m'; NC='\033[0m'
DB="/etc/smartking4luv/database.sqlite"; DOM=$(cat /etc/smartking4luv/domain 2>/dev/null)

select_vmess_user() {
    users=($(sqlite3 "$DB" "SELECT username FROM xray_users WHERE protocol='vmess';"))
    if [ ${#users[@]} -eq 0 ]; then echo -e " ${MAG}[!] No VMESS users found.${NC}"; return 1; fi
    echo -e "${MAG}┌─ REGISTERED VMESS ACCOUNTS ─────────────────────────────┐${NC}"
    local i=1
    for u in "${users[@]}"; do
        exp=$(sqlite3 "$DB" "SELECT expiry FROM xray_users WHERE username='$u';")
        printf " ${MAG}│${NC} ${GRN}[%02d]${NC} ${WHT}%-16s${NC} Exp: ${CYN}%-10s${NC}\n" "$i" "$u" "$exp"
        ((i++))
    done
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Enter choice [Number or Username]: " target
    if [[ "$target" =~ ^[0-9]+$ ]] && [ "$target" -ge 1 ] && [ "$target" -le ${#users[@]} ]; then SELECTED_USER="${users[$((target-1))]}"; else SELECTED_USER="$target"; fi
}

vmess_menu() {
  while true; do
    clear
    echo -e "${MAG}┌─ PROTOCOL MANAGEMENT ───────────────────────────────────┐${NC}"
    echo -e "${MAG}├── XRAY VMESS PROTOCOL MANAGER ─────────────────────────┤${NC}"
    echo -e "${MAG}│ ${GRN}[01]${CYN} Create VMESS Account                             ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[02]${CYN} Create Trial VMESS Account (24H)                 ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[03]${CYN} Renew / Extend Account                             ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[04]${CYN} Delete Account                                     ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}\n"
    echo -e "${MAG}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[00]${CYN} Back to Main Menu                                  ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"
    read -p " Select an option [00-04]: " opt
    case $opt in
      01|1) clear; echo -e "${MAG}┌─ CREATE VMESS ACCOUNT ──────────────────────────────────┐${NC}"
         read -p " Username: " u; read -p " Duration (Days): " d; id=$(uuidgen); e=$(date -d "+$d days" +"%Y-%m-%d")
         sqlite3 $DB "INSERT INTO xray_users VALUES ('$u','$id','vmess','$e');"
         clear; echo -e "${MAG}┌─ VMESS ACCOUNT DETAILS ──────────────────────────────────┐${NC}"
         echo -e " ${GRN}User : ${WHT}$u\n ${GRN}UUID : ${WHT}$id\n ${GRN}Exp  : ${WHT}$e"
         echo -e "${MAG}├─ CONNECTION LINKS ──────────────────────────────────────┤${NC}"
         if [ "vmess" == "vless" ]; then
             echo -e " ${CYN}[TLS 443]:${NC} ${WHT}vless://$id@$DOM:443?path=/xray&security=tls&encryption=none&type=ws#$u${NC}"
             echo -e " ${CYN}[Non-TLS 80]:${NC} ${WHT}vless://$id@$DOM:80?path=/xray&security=none&encryption=none&type=ws#$u${NC}"
         elif [ "vmess" == "vmess" ]; then
             echo -e " ${CYN}[VMess WS Link]:${NC}\n ${WHT}vmess://$(echo -n "{\"v\":\"2\",\"ps\":\"$u\",\"add\":\"$DOM\",\"port\":\"443\",\"id\":\"$id\",\"net\":\"ws\",\"path\":\"/xray\",\"tls\":\"tls\"}" | base64 -w 0)${NC}"
         elif [ "vmess" == "trojan" ]; then
             echo -e " ${CYN}[Trojan TLS Link]:${NC}\n ${WHT}trojan://$id@$DOM:443?path=/xray&security=tls&type=ws#$u${NC}"
         fi
         echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"; read -p " Press Enter..." ;;
      02|2) clear; echo -e "${MAG}┌─ GENERATING VMESS TRIAL ────────────────────────────────┐${NC}"
         u="vmess_trial_$((RANDOM % 899 + 100))"; id=$(uuidgen); e=$(date -d "+1 day" +"%Y-%m-%d")
         sqlite3 $DB "INSERT INTO xray_users VALUES ('$u','$id','vmess','$e');"
         echo -e " ${GRN}[+] Trial Account $u Generated (Exp: $e)${NC}\n UUID: $id"; read -p " Press Enter..." ;;
      03|3) clear; echo -e "${MAG}┌─ RENEW VMESS ACCOUNT ───────────────────────────────────┐${NC}"
         select_vmess_user || { read -p " Press Enter..."; continue; }
         read -p " Add Days: " d; e=$(date -d "+$d days" +"%Y-%m-%d")
         sqlite3 $DB "UPDATE xray_users SET expiry='$e' WHERE username='$SELECTED_USER';"
         echo -e " ${GRN}[+] Account $SELECTED_USER renewed to $e${NC}"; read -p " Press Enter..." ;;
      04|4) clear; echo -e "${MAG}┌─ DELETE VMESS ACCOUNT ──────────────────────────────────┐${NC}"
         select_vmess_user || { read -p " Press Enter..."; continue; }
         sqlite3 $DB "DELETE FROM xray_users WHERE username='$SELECTED_USER';"
         echo -e " ${GRN}[-] Account $SELECTED_USER removed.${NC}"; read -p " Press Enter..." ;;
      00|0) return ;;
    esac
  done
}
