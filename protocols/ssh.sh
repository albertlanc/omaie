#!/bin/bash
source /etc/smartking4luv/core/init.sh 2>/dev/null || true
ssh_menu() {
    while true; do
        clear
        echo -e "${CYAN}=======================================${NC}"
        echo -e "${YELLOW}      SSH & OPENVPN & DNSTT MANAGER    ${NC}"
        echo -e "${CYAN}=======================================${NC}"
        echo -e "1. Create New Account\n2. Renew Account\n3. Delete Account\n0. Back to Main Dashboard"
        read -p "Select Option: " opt
        case $opt in 1) create_ssh ;; 2) renew_ssh ;; 3) delete_ssh ;; 0) return ;; esac
    done
}
create_ssh() {
    clear; echo -e "${GREEN}--- Create SSH Account ---${NC}"
    read -p "Username: " user; read -p "Password: " pass
    read -p "Duration (Days): " days; read -p "Max Logins: " maxlogin; read -p "Quota (GB): " quota
    EXP=$(date -d "+$days days" +"%Y-%m-%d")
    DOMAIN=$(cat /etc/smartking4luv/domain); NS=$(cat /etc/smartking4luv/ns)
    sqlite3 "/etc/smartking4luv/database.sqlite" "INSERT INTO ssh_users (username, password, expiry, quota, max_login, status) VALUES ('$user', '$pass', '$EXP', $quota, $maxlogin, 'ACTIVE');"
    useradd -e "$EXP" -s /bin/false -M "$user"; echo "$user:$pass" | chpasswd
    clear
    echo -e "${CYAN}=======================================${NC}\n${GREEN}      ACCOUNT CREATED SUCCESSFULLY     ${NC}\n${CYAN}=======================================${NC}"
    echo -e "Username: $user\nPassword: $pass\nExpiry: $EXP\nMax Logins: $maxlogin\nQuota: ${quota}GB\n${CYAN}---------------------------------------${NC}"
    echo -e "${YELLOW}[HTTP Custom / Netmod WS Payload]${NC}\nGET wss://$DOMAIN/ HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf]Connection: Keep-Alive[crlf][crlf]"
    echo -e "${YELLOW}[SlowDNS Configuration]${NC}\nDomain: $DOMAIN\nNS: $NS\nPubKey: <dnstt_pubkey>"
    echo -e "${YELLOW}[OpenVPN Link]${NC}\nhttp://$DOMAIN:81/client-tcp-442.ovpn\n${CYAN}=======================================${NC}"
    read -p "Press Enter to return..."
}
renew_ssh() { read -p "Username to Renew: " user; read -p "Add Days: " days; NEW_EXP=$(date -d "+$days days" +"%Y-%m-%d"); usermod -e "$NEW_EXP" "$user"; sqlite3 "/etc/smartking4luv/database.sqlite" "UPDATE ssh_users SET expiry='$NEW_EXP' WHERE username='$user';"; echo "Renewed."; read -p "Press Enter..."; }
delete_ssh() { read -p "Username to Delete: " user; userdel -f "$user"; sqlite3 "/etc/smartking4luv/database.sqlite" "DELETE FROM ssh_users WHERE username='$user';"; echo "Deleted."; read -p "Press Enter..."; }
