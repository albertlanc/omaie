#!/bin/bash
monitor_menu() {
  clear; echo -e "\033[0;36m=== 📊 SYSTEM MONITOR ===\033[0m\n\033[1;33mBandwidth Usage:\033[0m"
  ifconfig | grep -E 'RX packets|TX packets'
  echo -e "\n\033[1;33mActive Connections:\033[0m"
  netstat -anp | grep ESTABLISHED | awk '{print $4, $5, $7}' | head -n 15
  read -p "Press Enter..."
}
