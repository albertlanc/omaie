#!/bin/bash
DB="/etc/smartking4luv/database.sqlite"; DOM=$(cat /etc/smartking4luv/domain 2>/dev/null); NS=$(cat /etc/smartking4luv/ns 2>/dev/null); IP=$(curl -sS ipv4.icanhazip.com 2>/dev/null)
HLINE="\033[0;36m==============================================================\033[0m"
SLINE="\033[0;36m--------------------------------------------------------------\033[0m"

ssh_menu() {
  while true; do
    clear; echo -e "$HLINE\n\033[1;37m                 SSH & OPENVPN MANAGER                        \033[0m\n$HLINE"
    echo -e "\033[1;32m [1]\033[0m Create Account\n\033[1;32m [2]\033[0m Renew Account\n\033[1;32m [3]\033[0m Delete Account\n\033[1;32m [4]\033[0m Lock/Unlock Account\n\033[1;32m [5]\033[0m Account Stats\n$SLINE\n\033[1;31m [0]\033[0m Back to Main Menu\n$HLINE"
    read -p " Select: " opt
    case $opt in
      1) clear; echo -e "$HLINE\n\033[1;37m                 CREATE SSH ACCOUNT                           \033[0m\n$HLINE"
         read -p " Username: " u; read -p " Password: " p; read -p " Days: " d; read -p " Max Logins: " m; read -p " Quota (GB): " q
         e=$(date -d "+$d days" +"%Y-%m-%d"); sqlite3 $DB "INSERT INTO ssh_users VALUES ('$u','$p','$e',$q,$m,'ACTIVE');"
         useradd -e "$e" -s /bin/false -M "$u" 2>/dev/null; echo "$u:$p" | chpasswd 2>/dev/null
         PUB=$(cat /etc/smartking4luv/slowdns_pub 2>/dev/null)
         clear; echo -e "$HLINE\n\033[1;32m                 ACCOUNT CREATED SUCCESSFULLY                 \033[0m\n$HLINE"
         echo -e " Username    : $u\n Password    : $p\n Expiry      : $e\n Max Login   : $m\n Data Quota  : ${q}GB\n Server IP   : $IP\n Domain      : $DOM\n Name Server : $NS"
         echo -e "$SLINE\n\033[1;33m                      PAYLOADS & CONFIGS                      \033[0m\n$SLINE"
         echo -e " \033[1;36m[WS/WSS Payload]\033[0m\n GET wss://$DOM/ HTTP/1.1[crlf]Host: $DOM[crlf]Upgrade: websocket[crlf][crlf]"
         echo -e "\n \033[1;36m[SlowDNS Config]\033[0m\n $DOM / $NS / $PUB"
         echo -e "\n \033[1;36m[OpenVPN Link]\033[0m\n http://$DOM:81/client.ovpn\n$HLINE"; read -p " Press Enter..." ;;
      2) clear; echo -e "$HLINE\n\033[1;37m                 RENEW SSH ACCOUNT                            \033[0m\n$HLINE\n Active Users:"
         sqlite3 $DB "SELECT username, expiry FROM ssh_users;" | column -t -s '|'; echo -e "$SLINE"
         read -p " Username: " u; read -p " Add Days: " d; e=$(date -d "+$d days" +"%Y-%m-%d"); usermod -e "$e" "$u" 2>/dev/null
         sqlite3 $DB "UPDATE ssh_users SET expiry='$e' WHERE username='$u'"; echo -e "\n \033[1;32m[+] Renewed to $e\033[0m"; read -p " Enter..." ;;
      3) clear; echo -e "$HLINE\n\033[1;37m                 DELETE SSH ACCOUNT                           \033[0m\n$HLINE\n Active Users:"
         sqlite3 $DB "SELECT username FROM ssh_users;" | column -t -s '|'; echo -e "$SLINE"
         read -p " Username: " u; userdel -f "$u" 2>/dev/null; sqlite3 $DB "DELETE FROM ssh_users WHERE username='$u'"; echo -e "\n \033[1;31m[-] Deleted\033[0m"; read -p " Enter..." ;;
      4) clear; echo -e "$HLINE\n\033[1;37m                 LOCK/UNLOCK ACCOUNT                          \033[0m\n$HLINE\n User Status:"
         sqlite3 $DB "SELECT username, status FROM ssh_users;" | column -t -s '|'; echo -e "$SLINE"
         read -p " Username: " u; read -p " Action (L=Lock / U=Unlock): " a
         if [[ "$a" == "L" || "$a" == "l" ]]; then usermod -L "$u" 2>/dev/null; sqlite3 $DB "UPDATE ssh_users SET status='LOCKED' WHERE username='$u'"; echo -e "\n \033[1;31m[x] Locked\033[0m"; fi
         if [[ "$a" == "U" || "$a" == "u" ]]; then usermod -U "$u" 2>/dev/null; sqlite3 $DB "UPDATE ssh_users SET status='ACTIVE' WHERE username='$u'"; echo -e "\n \033[1;32m[+] Unlocked\033[0m"; fi
         read -p " Enter..." ;;
      5) clear; echo -e "$HLINE\n\033[1;37m                 SSH ACCOUNT STATS                            \033[0m\n$HLINE"
         tot=$(sqlite3 $DB "SELECT count(*) FROM ssh_users;")
         on=$(netstat -anp 2>/dev/null | grep ESTABLISHED | grep sshd | wc -l)
         off=$((tot - on))
         echo -e " Total Accounts : $tot\n Online Users   : \033[1;32m$on\033[0m\n Offline Users  : \033[1;31m$off\033[0m\n$HLINE"; read -p " Press Enter..." ;;
      0) return ;;
    esac
  done
}
