#!/bin/bash
ssl_menu() {
    clear; echo -e "${CYAN}=== DOMAIN & SSL MANAGER ===${NC}"
    echo -e "1. Change Domain / NS\n2. Renew SSL Certificate (Acme.sh)\n0. Back"
    read -p "Option: " opt
    if [ "$opt" == "1" ]; then
        read -p "New Domain: " DOM; read -p "New NS: " NS
        echo "$DOM" > /etc/smartking4luv/domain; echo "$NS" > /etc/smartking4luv/ns
        echo "Updated."; read -p "Enter..."
    elif [ "$opt" == "2" ]; then
        echo "Requesting SSL for $(cat /etc/smartking4luv/domain)..."
        curl https://get.acme.sh | sh
        ~/.acme.sh/acme.sh --issue -d $(cat /etc/smartking4luv/domain) --standalone
        ~/.acme.sh/acme.sh --installcert -d $(cat /etc/smartking4luv/domain) --fullchainpath /etc/ssl/smartking.pem --keypath /etc/ssl/smartking.key
        systemctl restart haproxy stunnel4
        echo "SSL Renewed."; read -p "Enter..."
    fi
}
