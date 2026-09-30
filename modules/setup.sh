#!/bin/bash
install_core_deps() {
    apt update -y && apt upgrade -y
    apt install -y haproxy nginx stunnel4 dropbear squid openvpn wireguard sqlite3 ufw curl wget jq uuid-runtime iptables iptables-persistent socat cron build-essential cmake
    sqlite3 "/etc/smartking4luv/database.sqlite" "CREATE TABLE IF NOT EXISTS ssh_users (username TEXT PRIMARY KEY, password TEXT, expiry DATE, quota INTEGER, max_login INTEGER, status TEXT);"
    sqlite3 "/etc/smartking4luv/database.sqlite" "CREATE TABLE IF NOT EXISTS xray_users (username TEXT PRIMARY KEY, uuid TEXT, protocol TEXT, expiry DATE);"
}
configure_haproxy() {
    cat << 'HAPROXY' > /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    maxconn 4096
    tune.ssl.default-dh-param 2048
defaults
    log global
    mode tcp
    timeout connect 5s
    timeout client 50s
    timeout server 50s
frontend port_443
    bind *:443 ssl crt /etc/ssl/smartking.pem alpn h2,http/1.1
    mode tcp
    tcp-request inspect-delay 5s
    tcp-request content accept if { req_ssl_hello_type 1 }
    use_backend xray_backend if { req_ssl_sni -m end .xray.local }
    use_backend ssh_ws_backend if { req_ssl_sni -m end .ssh.local }
    default_backend ssh_ws_backend
frontend port_80
    bind *:80
    mode tcp
    use_backend xray_nontls if { req_ssl_sni -m end .xray.local }
    default_backend ssh_ws_nontls
backend xray_backend
    server xray 127.0.0.1:10001 check
backend ssh_ws_backend
    server sshws 127.0.0.1:10002 check
backend xray_nontls
    server xray_nt 127.0.0.1:10003 check
backend ssh_ws_nontls
    server sshws_nt 127.0.0.1:10004 check
HAPROXY
    systemctl restart haproxy
}
