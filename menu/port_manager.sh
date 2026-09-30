#!/bin/bash
port_menu() {
    clear; echo -e "${CYAN}=== PORT MANAGER ===${NC}"
    echo -e "Active Listening Ports:"
    ss -tulpn | grep -E 'haproxy|stunnel|dropbear|xray|squid|badvpn' | awk '{print $5, $7}'
    echo -e "\n(Dynamic port switching requires backend reboot)"
    read -p "Press Enter to return..."
}
