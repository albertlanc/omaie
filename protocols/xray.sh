#!/bin/bash
xray_menu() {
    while true; do
        clear
        echo -e "${CYAN}=======================================${NC}\n${YELLOW}      XRAY (VLESS/VMESS) MANAGER ${NC}\n${CYAN}=======================================${NC}"
        echo -e "1. Create Xray Account\n0. Back to Main Dashboard"
        read -p "Select Option: " opt
        case $opt in 1) create_xray ;; 0) return ;; esac
    done
}
create_xray() {
    clear; echo -e "${GREEN}--- Create Xray Account ---${NC}"
    read -p "Username: " user; read -p "Duration (Days): " days
    UUID=$(uuidgen); EXP=$(date -d "+$days days" +"%Y-%m-%d"); DOMAIN=$(cat /etc/smartking4luv/domain)
    sqlite3 "/etc/smartking4luv/database.sqlite" "INSERT INTO xray_users (username, uuid, protocol, expiry) VALUES ('$user', '$UUID', 'VLESS', '$EXP');"
    clear
    echo -e "${CYAN}=======================================${NC}\n${GREEN}    XRAY ACCOUNT CREATED SUCCESSFULLY  ${NC}\n${CYAN}=======================================${NC}"
    echo -e "Username : $user\nUUID     : $UUID\nExpiry   : $EXP\n${CYAN}---------------------------------------${NC}"
    echo -e "${YELLOW}[VLESS TLS - Port 443]${NC}\nvless://$UUID@$DOMAIN:443?path=/xray&security=tls&encryption=none&type=ws#$user"
    echo -e "\n${YELLOW}[VLESS Non-TLS - Port 80]${NC}\nvless://$UUID@$DOMAIN:80?path=/xray&security=none&encryption=none&type=ws#$user\n${CYAN}=======================================${NC}"
    read -p "Press Enter to return..."
}
