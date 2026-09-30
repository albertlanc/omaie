#!/bin/bash
wg_menu() {
    clear; echo -e "${CYAN}=== WIREGUARD MANAGER ===${NC}"
    read -p "Create WireGuard Client (User): " user
    IP="10.66.66.$(($RANDOM % 200 + 2))"
    PRIV=$(wg genkey); PUB=$(echo "$PRIV" | wg pubkey)
    DOM=$(cat /etc/smartking4luv/domain)
    echo -e "\n${YELLOW}[WireGuard Config - $user]${NC}"
    echo -e "[Interface]\nPrivateKey = $PRIV\nAddress = $IP/32\nDNS = 8.8.8.8\n\n[Peer]\nPublicKey = $(cat /etc/wireguard/publickey 2>/dev/null)\nEndpoint = $DOM:51820\nAllowedIPs = 0.0.0.0/0"
    read -p "Press Enter..."
}
