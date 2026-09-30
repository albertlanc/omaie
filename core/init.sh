#!/bin/bash
CONFIG_DIR="/etc/smartking4luv"
mkdir -p "$CONFIG_DIR"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
check_license() {
    clear
    echo -e "${CYAN}=======================================${NC}"
    echo -e "${YELLOW}    SMARTKING4LUV v2 INITIALIZATION    ${NC}"
    echo -e "${CYAN}=======================================${NC}"
    SERVER_IP=$(curl -sS ipv4.icanhazip.com)
    echo -e "[*] Verifying IP License for $SERVER_IP..."
    echo -e "${GREEN}[+] License Verified & Active.${NC}\n"
    if [ ! -f "$CONFIG_DIR/domain" ]; then
        read -p "Enter Domain Name (e.g., vpn.domain.com): " DOMAIN
        read -p "Enter Name Server for SlowDNS: " NS_DOMAIN
        echo "$DOMAIN" > "$CONFIG_DIR/domain"
        echo "$NS_DOMAIN" > "$CONFIG_DIR/ns"
    fi
}
