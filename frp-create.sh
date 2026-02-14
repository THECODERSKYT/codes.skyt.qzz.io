#!/bin/bash

CONFIG_FILE="frp/frpc.toml"

mkdir -p frp
[ ! -f "$CONFIG_FILE" ] && touch "$CONFIG_FILE"

ensure_login_fail_top() {
    if ! grep -q "^loginFailExit" "$CONFIG_FILE"; then
        sed -i '1iloginFailExit = false' "$CONFIG_FILE"
    else
        sed -i '/^loginFailExit/d' "$CONFIG_FILE"
        sed -i '1iloginFailExit = false' "$CONFIG_FILE"
    fi
}

get_value() {
    grep -E "^$1" "$CONFIG_FILE" | head -n1 | sed -E 's/.*=\s*"?([^"]*)"?/\1/'
}

setup_wizard() {
    clear
    echo "FRPC Setup Wizard"
    echo "----------------------------------"

    read -p "Server Address: " SADDR
    read -p "Server Port: " SPORT
    read -p "Auth Mode (default token): " AMODE
    AMODE=${AMODE:-token}
    read -p "Auth Token: " ATOKEN

    sed -i '/^serverAddr/d' "$CONFIG_FILE"
    sed -i '/^serverPort/d' "$CONFIG_FILE"
    sed -i '/^auth.method/d' "$CONFIG_FILE"
    sed -i '/^auth.token/d' "$CONFIG_FILE"

    {
        echo "serverAddr = \"$SADDR\""
        echo "serverPort = $SPORT"
        echo "auth.method = \"$AMODE\""
        echo "auth.token = \"$ATOKEN\""
    } >> "$CONFIG_FILE"

    ensure_login_fail_top
}

list_proxies() {
    awk '
    /\[\[proxies\]\]/{
        count++
        print count") Proxy"
        next
    }
    count>0 && NF{
        print "   "$0
    }
    ' "$CONFIG_FILE"
}

get_proxy_range() {
    awk -v n="$1" '
    /\[\[proxies\]\]/{c++}
    c==n{start=NR}
    c==n+1{end=NR-1}
    END{
        if(start && !end) end=NR
        if(start) print start":"end
    }
    ' "$CONFIG_FILE"
}

edit_proxy() {
    clear
    echo "Available Proxies"
    echo "----------------------------------"
    list_proxies
    echo "----------------------------------"
    read -p "Select Proxy Number: " PNUM

    RANGE=$(get_proxy_range "$PNUM")
    [ -z "$RANGE" ] && return

    START=$(echo $RANGE | cut -d: -f1)
    END=$(echo $RANGE | cut -d: -f2)

    while true; do
        clear
        echo "Editing Proxy $PNUM"
        echo "----------------------------------"
        sed -n "${START},${END}p" "$CONFIG_FILE"
        echo "----------------------------------"
        echo "1) Edit Name"
        echo "2) Edit Type"
        echo "3) Edit Local IP"
        echo "4) Edit Local Port"
        echo "5) Edit Remote Port"
        echo "0) Back"
        read -p "Select: " OPT

        case $OPT in
            1) FIELD="name"; QUOTE="yes" ;;
            2) FIELD="type"; QUOTE="yes" ;;
            3) FIELD="localIP"; QUOTE="yes" ;;
            4) FIELD="localPort"; QUOTE="no" ;;
            5) FIELD="remotePort"; QUOTE="no" ;;
            0) return ;;
            *) continue ;;
        esac

        OLD=$(sed -n "${START},${END}p" "$CONFIG_FILE" | grep "^$FIELD" | sed 's/.*= //')
        read -p "New value for $FIELD: " NEW

        echo "Old: $OLD"
        [ "$QUOTE" = "yes" ] && echo "New: \"$NEW\"" || echo "New: $NEW"
        read -p "Confirm change (y/n): " C
        [ "$C" != "y" ] && continue

        if [ "$QUOTE" = "yes" ]; then
            sed -i "${START},${END}s/^$FIELD.*/$FIELD = \"$NEW\"/" "$CONFIG_FILE"
        else
            sed -i "${START},${END}s/^$FIELD.*/$FIELD = $NEW/" "$CONFIG_FILE"
        fi

        read -p "Continue editing (y/n): " CONT
        [ "$CONT" != "y" ] && return
    done
}

create_proxy() {
    clear
    echo "Create New Proxy"
    echo "----------------------------------"

    read -p "Proxy Name: " PNAME
    read -p "Type (tcp/udp/http): " PTYPE
    read -p "Local IP (default 127.0.0.1): " LIP
    LIP=${LIP:-127.0.0.1}
    read -p "Local Port: " LPORT
    read -p "Remote Port: " RPORT

    {
        echo ""
        echo ""
        echo "[[proxies]]"
        echo "name = \"$PNAME\""
        echo "type = \"$PTYPE\""
        echo "localIP = \"$LIP\""
        echo "localPort = $LPORT"
        echo "remotePort = $RPORT"
    } >> "$CONFIG_FILE"
}

dashboard() {
    while true; do
        clear
        ensure_login_fail_top

        SERVER_ADDR=$(get_value "serverAddr")
        SERVER_PORT=$(get_value "serverPort")

        echo "FRPC Dashboard"
        echo "----------------------------------"
        echo "Server Address : ${SERVER_ADDR:-N/A}"
        echo "Server Port    : ${SERVER_PORT:-N/A}"
        echo "----------------------------------"
        echo ""
        echo "Configured Proxies:"
        list_proxies
        echo ""
        echo "----------------------------------"
        echo "1) Create Proxy"
        echo "2) Edit Proxy"
        echo "3) Setup Wizard"
        echo "0) Exit"
        echo "----------------------------------"

        read -p "Select Option: " CH

        case $CH in
            1) create_proxy ;;
            2) edit_proxy ;;
            3) setup_wizard ;;
            0) exit 0 ;;
        esac
    done
}

ensure_login_fail_top
dashboard
