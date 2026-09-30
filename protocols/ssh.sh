#!/bin/bash
source /etc/smartking4luv/core/init.sh 2>/dev/null || true
ssh_menu() {
    while true; do
        clear; echo -e "${CYAN}=== SSH & OPENVPN MANAGER ===${NC}"
        echo -e "1. Create Account\n2. Renew Account\n3. Delete Account\n4. Lock Account\n5. Unlock Account\n6. Active Users Stats\n0. Back"
        read -p "Option: " opt
        case $opt in 1) create_ssh ;; 2) renew_ssh ;; 3) delete_ssh ;; 4) lock_ssh ;; 5) unlock_ssh ;; 6) stats_ssh ;; 0) return ;; esac
    done
}
create_ssh() {
    clear; echo -e "${GREEN}--- Create SSH Account ---${NC}"
    read -p "User: " user; read -p "Pass: " pass; read -p "Days: " days; read -p "Quota (GB): " quota
    EXP=$(date -d "+$days days" +"%Y-%m-%d"); DOM=$(cat /etc/smartking4luv/domain); NS=$(cat /etc/smartking4luv/ns)
    sqlite3 "/etc/smartking4luv/database.sqlite" "INSERT INTO ssh_users (username, password, expiry, quota, status) VALUES ('$user', '$pass', '$EXP', $quota, 'ACTIVE');"
    useradd -e "$EXP" -s /bin/false -M "$user"; echo "$user:$pass" | chpasswd
    echo -e "\n${YELLOW}[Payloads for $user]${NC}\nWS: GET wss://$DOM/ HTTP/1.1[crlf]Host: $DOM[crlf]Upgrade: websocket[crlf][crlf]"
    echo -e "SlowDNS: $DOM / $NS / $(cat /etc/smartking4luv/slowdns_pub 2>/dev/null)"
    read -p "Press Enter..."
}
renew_ssh() { read -p "User: " u; read -p "Add Days: " d; EXP=$(date -d "+$d days" +"%Y-%m-%d"); usermod -e "$EXP" "$u"; sqlite3 "/etc/smartking4luv/database.sqlite" "UPDATE ssh_users SET expiry='$EXP' WHERE username='$u'"; echo "Renewed"; read -p "Enter..."; }
delete_ssh() { read -p "User: " u; userdel -f "$u"; sqlite3 "/etc/smartking4luv/database.sqlite" "DELETE FROM ssh_users WHERE username='$u'"; echo "Deleted"; read -p "Enter..."; }
lock_ssh() { read -p "User: " u; usermod -L "$u"; sqlite3 "/etc/smartking4luv/database.sqlite" "UPDATE ssh_users SET status='LOCKED' WHERE username='$u'"; echo "Locked"; read -p "Enter..."; }
unlock_ssh() { read -p "User: " u; usermod -U "$u"; sqlite3 "/etc/smartking4luv/database.sqlite" "UPDATE ssh_users SET status='ACTIVE' WHERE username='$u'"; echo "Unlocked"; read -p "Enter..."; }
stats_ssh() { clear; echo -e "${YELLOW}Active Connections:${NC}"; netstat -anp | grep ESTABLISHED | grep sshd; read -p "Press Enter..."; }
