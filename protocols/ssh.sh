#!/bin/bash
DB="/etc/smartking4luv/database.sqlite"; DOM=$(cat /etc/smartking4luv/domain 2>/dev/null); NS=$(cat /etc/smartking4luv/ns 2>/dev/null); IP=$(curl -sS ipv4.icanhazip.com 2>/dev/null); PUB=$(cat /etc/smartking4luv/slowdns_pub 2>/dev/null)
ssh_menu() {
  while true; do
    clear; echo -e "\033[0;36m=== 🔐 SSH & OPENVPN MANAGER ===\033[0m"
    echo -e "1. Create Account\n2. Renew Account\n3. Delete Account\n4. Lock/Unlock Account\n5. Account Stats\n0. Back"
    read -p "Select: " opt
    case $opt in
      1) clear; read -p "Username: " u; read -p "Password: " p; read -p "Days: " d; read -p "Max Logins: " m; read -p "Quota (GB): " q
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',$q,$m,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u"; echo "$u:$p" | chpasswd
         clear; echo -e "\033[1;32m=== ACCOUNT CREATED ===\033[0m\nUsername: $u\nPassword: $p\nExpiry: $e\nMax Login: $m\nData Quota: ${q}GB"
         echo -e "Server IP: $IP\nDomain: $DOM\nName Server: $NS\n\n\033[1;33mSupported Ports:\033[0m\n- SSH-WS: 80 / 443\n- SSL/Stunnel: 444\n- Dropbear: 109\n- SlowDNS: 5300\n- Squid: 8080, 3128\n- BadVPN/UDPGW: 7300\n\n\033[1;33m[Payloads]\033[0m"
         echo -e "WS/WSS: GET wss://$DOM/ HTTP/1.1[crlf]Host: $DOM[crlf]Upgrade: websocket[crlf][crlf]"
         echo -e "SlowDNS: $DOM / $NS / $PUB\nOpenVPN: http://$DOM:81/client.ovpn\n"; read -p "Press Enter..." ;;
      2) clear; echo -e "\033[1;33m--- Renew Account ---\033[0m\nActive Users:"; sqlite3 $DB "SELECT username, expiry FROM ssh_users;"
         read -p "Username: " u; read -p "Add Days: " d; e=$(date -d "+$d days" +"%Y-%m-%d"); usermod -e "$e" "$u"
         sqlite3 $DB "UPDATE ssh_users SET expiry='$e' WHERE username='$u'"; echo "Renewed to $e"; read -p "Enter..." ;;
      3) clear; echo -e "\033[1;31m--- Delete Account ---\033[0m\nActive Users:"; sqlite3 $DB "SELECT username FROM ssh_users;"
         read -p "Username: " u; userdel -f "$u"; sqlite3 $DB "DELETE FROM ssh_users WHERE username='$u'"; echo "Deleted"; read -p "Enter..." ;;
      4) clear; echo -e "\033[1;34m--- Lock/Unlock ---\033[0m\nUser Status:"; sqlite3 $DB "SELECT username, status FROM ssh_users;"
         read -p "Username: " u; read -p "Lock(L) or Unlock(U)?: " a
         if [[ "$a" == "L" || "$a" == "l" ]]; then usermod -L "$u"; sqlite3 $DB "UPDATE ssh_users SET status='LOCKED' WHERE username='$u'"; echo "Locked"; fi
         if [[ "$a" == "U" || "$a" == "u" ]]; then usermod -U "$u"; sqlite3 $DB "UPDATE ssh_users SET status='ACTIVE' WHERE username='$u'"; echo "Unlocked"; fi
         read -p "Enter..." ;;
      5) clear; echo -e "\033[1;36m--- SSH Stats ---\033[0m"
         tot=$(sqlite3 $DB "SELECT count(*) FROM ssh_users;"); on=$(netstat -anp | grep ESTABLISHED | grep sshd | wc -l); off=$((tot - on))
         echo -e "Total Accounts: $tot\nOnline Users: $on\nOffline Users: $off"; read -p "Enter..." ;;
      0) return ;;
    esac
  done
}
