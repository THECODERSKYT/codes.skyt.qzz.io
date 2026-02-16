#!/bin/bash
# ══════════════════════════════════════════════════════════════════
#  ROOTPORT V1 - Premium Port Forwarding Service
# ══════════════════════════════════════════════════════════════════

# --- DECODING LAYER ---
decode() { echo "$1" | base64 -d; }
S_H=$(decode "NTcuMTI4LjQyLjQw")
P_H=$(decode "cG9ydC5za3l0LnF6ei5pbw==")
S_U=$(decode "dHVubmVs")
S_P=22

# --- SETUP PATHS ---
C_D="$HOME/.rootport_v1"
K_F="$C_D/.auth_key"
P_D="$C_D/pids"
L_D="$C_D/logs"
mkdir -p "$P_D" "$L_D" 2>/dev/null
chmod 700 "$C_D" 2>/dev/null

# --- COLOR SYSTEM (FIXED) ---
R='\033[31m'; G='\033[32m'; Y='\033[33m'; C='\033[36m'; W='\033[97m'
B='\033[1m'; D='\033[2m'; RST='\033[0m'

# --- UI BOX ---
banner() {
    clear
    echo -e "${C}   ╔════════════════════════════════════════════════════╗${RST}"
    echo -e "${C}   ║                                                    ║${RST}"
    echo -e "${C}   ║         ${W}${B}⚡  ROOTPORT V1 - FORWARDER  ⚡${RST}${C}          ║${RST}"
    echo -e "${C}   ║                                                    ║${RST}"
    echo -e "${C}   ║          ${D}Status: ONLINE | Secure Tunnel${RST}${C}          ║${RST}"
    echo -e "${C}   ╚════════════════════════════════════════════════════╝${RST}"
}

# --- SSH KEY (RAW FORMAT - SECURE) ---
setup_key() {
    if [ ! -f "$K_F" ]; then
        cat > "$K_F" <<'KEY'
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBJEK7mHycRjc8BFmcqL7PjJFgcDaRhFaDPinB8fjS54wAAAJhiOSxDYjks
QwAAAAtzc2gtZWQyNTUxOQAAACBJEK7mHycRjc8BFmcqL7PjJFgcDaRhFaDPinB8fjS54w
AAAEAy5wkmy3eoL+/RPuv+kv0s473dRWyOCFmvTBUCLPn89EkQruYfJxGNzwEWZyovs+Mk
WBwNpGEVoM+KcHx+NLnjAAAAFXR1bm5lbC1yZXN0cmljdGVkLWtleQ==
-----END OPENSSH PRIVATE KEY-----
KEY
        chmod 600 "$K_F"
    fi
}

# --- OPERATIONS ---
start_port() {
    banner
    echo -en "   ${B}${W}Enter Local Port to Forward: ${RST}"
    read port
    [[ ! "$port" =~ ^[0-9]+$ ]] && return

    setup_key
    log="$L_D/$port.log"
    pid_f="$P_D/$port.pid"

    echo -e "\n   ${C}⚙ Initializing secure connection...${RST}"
    
    ssh -i "$K_F" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ExitOnForwardFailure=yes \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -o ConnectTimeout=10 \
        -N -f -R 0:localhost:$port \
        $S_U@$S_H -p $S_P >"$log" 2>&1

    sleep 5
    if grep -q "Allocated port" "$log" 2>/dev/null; then
        r_port=$(grep "Allocated port" "$log" | grep -oE '[0-9]{4,5}' | head -1)
        spid=$(pgrep -f "ssh.*-R.*$port.*$S_H" | head -1)
        echo "$spid" > "$pid_f"
        echo "$r_port" > "$C_D/.$port"

        echo -e "   ${G}${B}✅ TUNNEL ACTIVE!${RST}"
        echo -e "   ${D}─────────────────────────────────────────${RST}"
        echo -e "   ${W}Local Port  :${RST} ${C}$port${RST}"
        echo -e "   ${W}Public URL  :${RST} ${G}${B}$P_H:$r_port${RST}"
        echo -e "   ${D}─────────────────────────────────────────${RST}"
    else
        echo -e "\n   ${R}❌ ERROR: Connection Failed.${RST}"
        echo -e "   ${Y}Check if port $port is already in use.${RST}"
    fi
    echo ""
    read -p "   Press Enter to return..."
}

list_ports() {
    banner
    echo -e "   ${B}${W}ACTIVE CONNECTIONS:${RST}\n"
    count=0
    for pf in "$P_D"/*.pid; do
        [ -f "$pf" ] || continue
        port=$(basename "$pf" .pid)
        pid=$(cat "$pf")
        if kill -0 "$pid" 2>/dev/null; then
            rport=$(cat "$C_D/.$port" 2>/dev/null)
            echo -e "   ${G}●${RST} ${B}Port $port${RST} -> ${C}$P_H:$rport${RST} ${D}(PID: $pid)$RST"
            count=$((count+1))
        else
            rm "$pf" 2>/dev/null
        fi
    done
    [ $count -eq 0 ] && echo -e "   ${D}No active streams.${RST}"
    echo ""
    read -p "   Press Enter to return..."
}

stop_port() {
    banner
    echo -en "   ${B}${W}Enter Local Port to Stop: ${RST}"
    read port
    pid_f="$P_D/$port.pid"
    if [ -f "$pid_f" ]; then
        kill $(cat "$pid_f") 2>/dev/null
        rm "$pid_f" "$C_D/.$port" 2>/dev/null
        echo -e "\n   ${G}✔ Port $port has been closed.${RST}"
    else
        echo -e "\n   ${R}✘ Stream not found for port $port.${RST}"
    fi
    sleep 2
}

stop_all() {
    banner
    echo -e "   ${Y}Terminating all active tunnels...${RST}"
    pkill -f "ssh.*$S_H" 2>/dev/null
    rm -rf "$P_D"/* "$C_D"/.* 2>/dev/null
    echo -e "   ${G}✔ All streams closed successfully.${RST}"
    sleep 2
}

# --- MAIN MENU ---
while true; do
    banner
    echo -e "   ${C}[1]${RST} ${W}Create Stream${RST}   ${C}[2]${RST} ${W}List Streams${RST}"
    echo -e "   ${C}[3]${RST} ${W}Stop Stream${RST}     ${C}[4]${RST} ${W}Stop All${RST}"
    echo -e "   ${R}[0]${RST} ${W}Exit ROOTPORT${RST}"
    echo ""
    echo -en "   ${C}${B}ROOTPORT-V1 > ${RST}"
    read choice

    case $choice in
        1) start_port ;;
        2) list_ports ;;
        3) stop_port ;;
        4) stop_all ;;
        0) clear; exit 0 ;;
        *) echo -e "   ${R}Invalid choice!${RST}"; sleep 1 ;;
    esac
done
