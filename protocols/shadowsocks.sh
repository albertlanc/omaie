#!/bin/bash
ss_menu() {
  while true; do
    clear; echo -e "\033[0;36m==============================================================\n\033[1;37m                 SHADOWSOCKS MANAGER                          \033[0m\n\033[0;36m==============================================================\033[0m"
    echo -e "\033[1;32m [1]\033[0m Create SS Account\n\033[1;32m [2]\033[0m Renew Account\n\033[1;32m [3]\033[0m Delete Account\n\033[0;36m--------------------------------------------------------------\033[0m\n\033[1;31m [0]\033[0m Back to Main Menu\n\033[0;36m==============================================================\033[0m"
    read -p " Select: " opt
    case $opt in
      1) read -p " Username: " u; read -p " Days: " d; id=$(uuidgen); e=$(date -d "+$d days" +"%Y-%m-%d")
         sqlite3 /etc/smartking4luv/database.sqlite "INSERT INTO xray_users VALUES ('$u','$id','ss','$e');"
         echo -e "\n \033[1;32m[+] Shadowsocks Account Created\033[0m"; read -p " Enter..." ;;
      0) return ;;
      *) echo "WIP"; sleep 1 ;;
    esac
  done
}
