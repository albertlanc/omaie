#!/bin/bash
CLIENT_IP=$(curl -s https://api.ipify.org)
AUTHORIZED_IPS="https://raw.githubusercontent.com/albertlanc/omaie/main/licensed_ips.txt"

if ! curl -s "$AUTHORIZED_IPS" | grep -qw "$CLIENT_IP"; then
    echo "[-] Access Denied! Your IP ($CLIENT_IP) is not licensed to run this script."
    exit 1
fi
echo "[+] License Verified for IP: $CLIENT_IP"
echo "[+] Proceeding with system setup..."
# Your automated setup commands will go below this line
