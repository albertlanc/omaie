#!/bin/bash
source core/init.sh; source modules/setup.sh; source modules/advanced_setup.sh
source protocols/ssh.sh; source protocols/xray.sh; source protocols/wireguard.sh
source menu/ssl_manager.sh; source menu/port_manager.sh; source menu/dashboard.sh
source menu/monitor.sh; source menu/uninstall.sh

check_license
# Hook advanced setup into first-time install if not run yet
if [ ! -f "/etc/smartking4luv/advanced_installed" ]; then
    setup_squid_udp_ovpn
    touch /etc/smartking4luv/advanced_installed
fi

while true; do
    show_dashboard
    read -p "Select Menu: " opt
    case $opt in
        1) ssh_menu ;;
        2) xray_menu ;;
        3) wg_menu ;;
        4) ssl_menu ;;
        5) port_menu ;;
        6) monitor_menu ;;
        7) uninstall_menu ;;
        0) clear; exit 0 ;;
    esac
done
