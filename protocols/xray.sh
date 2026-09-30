#!/bin/bash
xray_menu() {
    while true; do
        clear; echo -e "${CYAN}=== XRAY (VLESS/TROJAN/SS) MANAGER ===${NC}"
        echo -e "1. Create VLESS Account\n2. Create Shadowsocks Account\n0. Back"
        read -p "Option: " opt
        case $opt in 1) create_xray vless ;; 2) create_xray ss ;; 0) return ;; esac
    done
}
create_xray() {
    clear; echo -e "${GREEN}--- Create $1 Account ---${NC}"
    read -p "User: " user; read -p "Days: " days
    UUID=$(uuidgen); EXP=$(date -d "+$days days" +"%Y-%m-%d"); DOM=$(cat /etc/smartking4luv/domain)
    sqlite3 "/etc/smartking4luv/database.sqlite" "INSERT INTO xray_users (username, uuid, protocol, expiry) VALUES ('$user', '$UUID', '$1', '$EXP');"
    echo -e "\n${YELLOW}[$1 Configuration for $user]${NC}\nUUID/Pass: $UUID\nExpiry: $EXP"
    if [ "$1" == "vless" ]; then
        echo -e "TLS: vless://$UUID@$DOM:443?path=/xray&security=tls&type=ws#$user"
    else
        echo -e "SS: ss://$(echo -n "aes-128-gcm:$UUID" | base64)@$DOM:10005#$user"
    fi
    read -p "Press Enter..."
}
