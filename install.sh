#!/bin/bash
source core/init.sh; source modules/setup.sh; source protocols/ssh.sh; source protocols/xray.sh; source menu/dashboard.sh
check_license
while true; do
    show_dashboard
    read -p "Select Menu: " opt
    case $opt in
        1) ssh_menu ;; 2) xray_menu ;;
        7) read -p "Completely remove? (y/n): " conf; if [[ "$conf" == "y" ]]; then rm -rf /etc/smartking4luv; exit 0; fi ;;
        0) clear; exit 0 ;;
        *) echo "Invalid"; sleep 1 ;;
    esac
done
