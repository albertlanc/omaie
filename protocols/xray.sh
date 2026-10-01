#!/bin/bash
DB="/etc/smartking4luv/database.sqlite"; DOM=$(cat /etc/smartking4luv/domain 2>/dev/null)
xray_menu() {
  while true; do
    clear; echo -e "\033[0;36m=== 🚀 XRAY & SS MANAGER ===\033[0m"
    echo -e "1. Create (Vless/Vmess/Trojan/SS)\n2. Renew Account\n3. Delete Account\n0. Back"
    read -p "Select: " opt
    case $opt in
      1) clear; read -p "Protocol (vless/vmess/trojan/ss): " pr; read -p "Username: " u; read -p "Days: " d
         id=$(uuidgen); e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO xray_users VALUES ('$u','$id','$pr','$e');"
         clear; echo -e "\033[1;32m=== $pr ACCOUNT CREATED ===\033[0m\nUser: $u | UUID: $id | Expiry: $e\n\033[1;33m[Payload Links]\033[0m"
         if [ "$pr" == "vless" ]; then echo -e "TLS (443): vless://$id@$DOM:443?path=/xray&security=tls&encryption=none&type=ws#$u\nNon-TLS (80): vless://$id@$DOM:80?path=/xray&security=none&encryption=none&type=ws#$u"; fi
         if [ "$pr" == "vmess" ]; then echo -e "VMess WS: vmess://$(echo -n "{\"v\":\"2\",\"ps\":\"$u\",\"add\":\"$DOM\",\"port\":\"443\",\"id\":\"$id\",\"net\":\"ws\",\"path\":\"/xray\",\"tls\":\"tls\"}" | base64 -w 0)"; fi
         if [ "$pr" == "trojan" ]; then echo -e "Trojan TLS: trojan://$id@$DOM:443?path=/xray&security=tls&type=ws#$u"; fi
         if [ "$pr" == "ss" ]; then echo -e "Shadowsocks SR: ss://$(echo -n "aes-128-gcm:$id" | base64 -w 0)@$DOM:10005#$u"; fi
         read -p "Enter..." ;;
      2) clear; echo "Xray Accounts:"; sqlite3 $DB "SELECT username, protocol, expiry FROM xray_users;"; read -p "User to Renew: " u; read -p "Add Days: " d
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "UPDATE xray_users SET expiry='$e' WHERE username='$u'"; echo "Renewed"; read -p "Enter..." ;;
      3) clear; echo "Xray Accounts:"; sqlite3 $DB "SELECT username, protocol FROM xray_users;"; read -p "User to Delete: " u
         sqlite3 $DB "DELETE FROM xray_users WHERE username='$u'"; echo "Deleted"; read -p "Enter..." ;;
      0) return ;;
    esac
  done
}
