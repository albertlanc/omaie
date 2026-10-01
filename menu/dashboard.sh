#!/bin/bash
MAG='\033[1;35m'; GRN='\033[1;32m'; CYN='\033[1;36m'; WHT='\033[1;37m'; NC='\033[0m'
get_status() { systemctl is-active --quiet $1 && echo -e "${GRN}[OK]${NC}" || echo -e "\033[1;31m[OFF]${NC}"; }

show_dashboard() {
    clear
    UP=$(uptime -p | cut -d " " -f 2-)
    RAM_P=$(free -m | awk '/Mem:/ { printf("%3.1f%%", $3/$2*100) }')
    RAM_U=$(free -m | awk '/Mem:/ { print $3 }')
    RAM_T=$(free -m | awk '/Mem:/ { print $2 }')
    DOM=$(cat /etc/smartking4luv/domain 2>/dev/null || echo "Not Set")
    IP=$(curl -sS ipv4.icanhazip.com 2>/dev/null)
    LOAD=$(cat /proc/loadavg | awk '{print $1}')
    DISK=$(df -h / | awk '/\// {print $5 " of " $2}')

    echo -e "${GRN}System load:            ${WHT}$LOAD${NC}"
    echo -e "${GRN}Usage of /:             ${WHT}$DISK${NC}"
    echo -e "${GRN}Memory usage:           ${WHT}$RAM_P${NC}"
    echo -e "${GRN}* Management:           ${WHT}SMARTKING4LUV v2 PRO${NC}"
    echo -e "${GRN}* Support:              ${WHT}https://github.com/albertlanc${NC}\n"

    echo -e "${MAG}┌─ SMARTKING4LUV V2 PRO (ELITE) ──────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}Host : ${WHT}$HOSTNAME ($IP) ${NC}"
    echo -e "${MAG}│ ${GRN}Up   : ${WHT}$UP ${NC}"
    echo -e "${MAG}│ ${GRN}RAM  : ${WHT}[##--------] $RAM_P (${RAM_U}MB/${RAM_T}MB) ${NC}"
    echo -e "${MAG}│ ${GRN}SVC  : ${WHT}Xray:$(get_status xray) SSH:$(get_status stunnel4) OVPN:$(get_status openvpn) WG:$(get_status wg-quick@wg0)${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}\n"

    echo -e "${MAG}┌─ PROTOCOL MANAGEMENT ───────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[01]${CYN} SSH, SSHWS & UDP Custom Manager                    ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[02]${CYN} OpenVPN Manager                                    ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[03]${CYN} Xray VLESS Manager                                 ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[04]${CYN} Xray VMESS Manager                                 ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[05]${CYN} Xray Trojan Manager                                ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[06]${CYN} Shadowsocks Manager                                ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[07]${CYN} WireGuard Manager                                  ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}\n"

    echo -e "${MAG}┌─ SERVER & AUTOMATION ───────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[08]${CYN} SSL/TLS & Domain Manager                           ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[09]${CYN} Service & Port Manager                             ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}\n"

    echo -e "${MAG}┌─ DIAGNOSTICS & TOOLS ───────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[10]${CYN} Monitoring & Tools                                 ${MAG}│${NC}"
    echo -e "${MAG}│ ${GRN}[11]${CYN} Uninstall System                                   ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}\n"

    echo -e "${MAG}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAG}│ ${GRN}[00]${CYN} Exit Dashboard                                     ${MAG}│${NC}"
    echo -e "${MAG}└─────────────────────────────────────────────────────────┘${NC}"
}
