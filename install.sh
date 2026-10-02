#!/bin/bash
source core/init.sh; source modules/setup.sh; source modules/advanced_setup.sh
source protocols/ssh.sh; source protocols/openvpn.sh
source protocols/vless.sh; source protocols/vmess.sh; source protocols/trojan.sh; source protocols/shadowsocks.sh
source protocols/wireguard.sh; source menu/ssl_manager.sh; source menu/port_manager.sh
source menu/monitor.sh; source menu/uninstall.sh; source menu/dashboard.sh

check_license
while true; do
    show_dashboard
    read -p " Select an option [00-12]: " opt
    case $opt in
        01|1) ssh_menu ;; 02|2) openvpn_menu ;; 03|3) vless_menu ;; 04|4) vmess_menu ;; 05|5) trojan_menu ;;
        06|6) ss_menu ;; 07|7) wg_menu ;; 08|8) ssl_menu ;; 09|9) port_menu ;; 10) monitor_menu ;; 
        11) clear; read -p " Reboot System? (y/n): " rb; if [ "$rb" == "y" ]; then reboot; fi ;;
        12) uninstall_menu ;; 00|0) clear; exit 0 ;;
    esac
done

# ==========================================
# NEW UNIFIED WS-PROXY SCRIPT & PROTOCOL FIXES
# ==========================================
echo "Applying updated Smart ws-proxy and protocol paths..."

cat << 'PROXY_EOF' > /usr/local/bin/ws-proxy.py
import socket, threading, time

LOG_FILE = "/var/log/ws-proxy.log"

def log(msg):
    try:
        with open(LOG_FILE, "a") as f:
            f.write(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {msg}\n")
    except: pass

def fwd(s, d):
    try:
        while True:
            data = s.recv(8192)
            if not data: break
            d.sendall(data)
    except: pass
    finally:
        for sock in [s, d]:
            try: sock.close()
            except: pass

def handle(c):
    try:
        c.settimeout(5.0)
        data = c.recv(8192)
        c.settimeout(None)
        
        if not data:
            c.close()
            return

        lower_data = data.lower()
        b = socket.socket()
        
        if b"get /vmess" in lower_data:
            log("Routing to VMess (Port 10002)")
            b.connect(("127.0.0.1", 10002))
            b.sendall(data)
        elif b"get /trojan" in lower_data:
            log("Routing to Trojan (Port 10003)")
            b.connect(("127.0.0.1", 10003))
            b.sendall(data)
        elif b"get /xray" in lower_data or b"get / " in lower_data:
            log("Routing to VLESS/Xray (Port 10001)")
            b.connect(("127.0.0.1", 10001))
            b.sendall(data)
        elif b"connect" in lower_data:
            log("Routing SSH CONNECT (Port 22)")
            c.sendall(b"HTTP/1.1 200 Connection Established\r\n\r\n")
            b.connect(("127.0.0.1", 22))
            parts = data.split(b"\r\n\r\n", 1)
            if len(parts) > 1 and parts[1]:
                b.sendall(parts[1])
        elif b"upgrade: websocket" in lower_data:
            log("Routing SSH WebSocket (Port 22)")
            c.sendall(b"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n")
            b.connect(("127.0.0.1", 22))
            parts = data.split(b"\r\n\r\n", 1)
            if len(parts) > 1 and parts[1]:
                b.sendall(parts[1])
        else:
            log("Routing SSH Fallback (Port 22)")
            b.connect(("127.0.0.1", 22))
            b.sendall(data)

        threading.Thread(target=fwd, args=(c, b), daemon=True).start()
        threading.Thread(target=fwd, args=(b, c), daemon=True).start()
    except Exception as e:
        log(f"Error: {e}")
        try: c.close()
        except: pass

s = socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 8880)); s.listen(200)
log("WS-Proxy started on port 8880")
while True:
    c, _ = s.accept()
    threading.Thread(target=handle, args=(c,), daemon=True).start()
PROXY_EOF

# Initialize Proxy Log
touch /var/log/ws-proxy.log
chmod 666 /var/log/ws-proxy.log

# Force patch the dashboard protocol paths dynamically
sed -i 's/"path":"\/xray"/"path":"\/vmess"/g' ./protocols/vmess.sh 2>/dev/null
sed -i 's/"path":"\/xray"/"path":"\/trojan"/g' ./protocols/trojan.sh 2>/dev/null

# Restart the service to apply the new proxy behavior
systemctl restart ws-proxy
echo "Multi-protocol fixes applied successfully."
# ==========================================

# ==========================================
# DYNAMIC XRAY CONFIG FIX FOR FRESH VM
# ==========================================
echo "Patching Xray backend paths for VMess and Trojan..."
python3 -c '
import json, os
conf_path = "/usr/local/etc/xray/config.json"
if os.path.exists(conf_path):
    try:
        with open(conf_path, "r") as f:
            data = json.load(f)
        for ib in data.get("inbounds", []):
            if ib.get("port") == 10002 and "streamSettings" in ib:
                ib["streamSettings"]["wsSettings"]["path"] = "/vmess"
            elif ib.get("port") == 10003 and "streamSettings" in ib:
                ib["streamSettings"]["wsSettings"]["path"] = "/trojan"
        with open(conf_path, "w") as f:
            json.dump(data, f, indent=2)
    except Exception as e:
        print(f"Failed to patch Xray config: {e}")
'
# Restart Xray to apply backend paths
systemctl restart xray
# ==========================================
