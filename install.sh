#!/bin/bash
source core/init.sh; source modules/setup.sh; source modules/advanced_setup.sh
source protocols/ssh.sh; source protocols/openvpn.sh
source protocols/vless.sh; source protocols/vmess.sh; source protocols/trojan.sh; source protocols/shadowsocks.sh
source protocols/wireguard.sh; source menu/ssl_manager.sh; source menu/port_manager.sh
source menu/monitor.sh; source menu/uninstall.sh; source menu/dashboard.sh

check_license
while true; do
    show_dashboard
    read -p " Select Menu: " opt
    case $opt in
        1) ssh_menu ;; 2) openvpn_menu ;; 3) vless_menu ;; 4) vmess_menu ;; 5) trojan_menu ;;
        6) ss_menu ;; 7) wg_menu ;; 8) ssl_menu ;; 9) monitor_menu ;; 10) uninstall_menu ;; 0) clear; exit 0 ;;
    esac
done
