#!/bin/bash
source core/init.sh; source modules/setup.sh; source modules/advanced_setup.sh
source protocols/ssh.sh; source protocols/openvpn.sh
source protocols/vless.sh; source protocols/vmess.sh; source protocols/trojan.sh; source protocols/shadowsocks.sh
source protocols/wireguard.sh; source menu/ssl_manager.sh; source menu/port_manager.sh
source menu/monitor.sh; source menu/uninstall.sh; source menu/dashboard.sh

check_license
while true; do
    show_dashboard
    read -p " Select an option [00-12]: " opt
    case $opt in
        01|1) ssh_menu ;; 02|2) openvpn_menu ;; 03|3) vless_menu ;; 04|4) vmess_menu ;; 05|5) trojan_menu ;;
        06|6) ss_menu ;; 07|7) wg_menu ;; 08|8) ssl_menu ;; 09|9) port_menu ;; 10) monitor_menu ;; 
        11) clear; read -p " Reboot System? (y/n): " rb; if [ "$rb" == "y" ]; then reboot; fi ;;
        12) uninstall_menu ;; 00|0) clear; exit 0 ;;
    esac
done
