#!/bin/bash
openvpn_menu() {
  while true; do
    clear; echo -e "\033[0;36m==============================================================\n\033[1;37m                 OPENVPN MANAGER                              \033[0m\n\033[0;36m==============================================================\033[0m"
    echo -e "\033[1;32m [1]\033[0m Create OpenVPN Account\n\033[1;32m [2]\033[0m Renew Account\n\033[1;32m [3]\033[0m Delete Account\n\033[0;36m--------------------------------------------------------------\033[0m\n\033[1;31m [0]\033[0m Back to Main Menu\n\033[0;36m==============================================================\033[0m"
    read -p " Select: " opt
    case $opt in
      1) read -p " Username: " u; read -p " Password: " p; read -p " Days: " d
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 /etc/smartking4luv/database.sqlite "INSERT INTO ssh_users (username, password, expiry, status) VALUES ('$u','$p','$e','ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         echo -e "\n \033[1;32m[+] OpenVPN Account Created\033[0m\n Config: http://$(cat /etc/smartking4luv/domain):81/client.ovpn"; read -p " Enter..." ;;
      0) return ;;
      *) echo "WIP"; sleep 1 ;;
    esac
  done
}
