#!/bin/bash

CONFIG_FILE="frp/frpc.toml"

mkdir -p frp
[ ! -f "$CONFIG_FILE" ] && touch "$CONFIG_FILE"

ensure_login_fail() {
    if ! grep -q "^loginFailExit" "$CONFIG_FILE"; then
        echo "" >> "$CONFIG_FILE"
        echo "loginFailExit = false" >> "$CONFIG_FILE"
    fi
}

get_value() {
    grep -E "^$1" "$CONFIG_FILE" | head -n1 | sed -E 's/.*=\s*"?([^"]*)"?/\1/' 2>/dev/null
}

setup_wizard() {
    clear
    echo "FRPC Setup Wizard"
    echo "--------------------------------------"

    read -p "Server Address: " SADDR
    read -p "Server Port: " SPORT

    read -p "Auth Mode (default token): " AMODE
    AMODE=${AMODE:-token}

    read -p "Auth Token: " ATOKEN

    sed -i '/^serverAddr/d' "$CONFIG_FILE"
    sed -i '/^serverPort/d' "$CONFIG_FILE"
    sed -i '/^auth.method/d' "$CONFIG_FILE"
    sed -i '/^auth.token/d' "$CONFIG_FILE"

    echo "serverAddr = \"$SADDR\"" >> "$CONFIG_FILE"
    echo "serverPort = $SPORT" >> "$CONFIG_FILE"
    echo "auth.method = \"$AMODE\"" >> "$CONFIG_FILE"
    echo "auth.token = \"$ATOKEN\"" >> "$CONFIG_FILE"

    ensure_login_fail
}

list_proxies() {
    awk '
    BEGIN{count=0}
    /\[\[proxies\]\]/{count++; print count") Proxy"; next}
    count>0 && NF{print "   "$0}
    ' "$CONFIG_FILE"
}

get_proxy_block() {
    awk -v num="$1" '
    /\[\[proxies\]\]/{c++}
    c==num{print}
    c>num && /\[\[proxies\]\]/{exit}
    ' "$CONFIG_FILE"
}

edit_proxy() {
    clear
    echo "Available Proxies"
    echo "--------------------------------------"
    list_proxies
    echo "--------------------------------------"
    read -p "Select Proxy Number: " PNUM

    BLOCK=$(get_proxy_block "$PNUM")
    [ -z "$BLOCK" ] && return

    while true; do
        clear
        echo "Editing Proxy $PNUM"
        echo "--------------------------------------"
        echo "$BLOCK"
        echo "--------------------------------------"
        echo "1) Edit Name"
        echo "2) Edit Type"
        echo "3) Edit Local IP"
        echo "4) Edit Local Port"
        echo "5) Edit Remote Port"
        echo "0) Back"
        read -p "Select: " OPT

        case $OPT in
            1)
                OLD=$(echo "$BLOCK" | grep name | sed 's/.*= //')
                read -p "New Name: " NEW
                echo "Old: $OLD"
                echo "New: \"$NEW\""
                read -p "Confirm (y/n): " C
                [ "$C" == "y" ] && sed -i "0,/name = .*/s//name = \"$NEW\"/" "$CONFIG_FILE"
                ;;
            2)
                OLD=$(echo "$BLOCK" | grep type | sed 's/.*= //')
                read -p "New Type: " NEW
                echo "Old: $OLD"
                echo "New: \"$NEW\""
                read -p "Confirm (y/n): " C
                [ "$C" == "y" ] && sed -i "0,/type = .*/s//type = \"$NEW\"/" "$CONFIG_FILE"
                ;;
            3)
                OLD=$(echo "$BLOCK" | grep localIP | sed 's/.*= //')
                read -p "New Local IP: " NEW
                echo "Old: $OLD"
                echo "New: \"$NEW\""
                read -p "Confirm (y/n): " C
                [ "$C" == "y" ] && sed -i "0,/localIP = .*/s//localIP = \"$NEW\"/" "$CONFIG_FILE"
                ;;
            4)
                OLD=$(echo "$BLOCK" | grep localPort | sed 's/.*= //')
                read -p "New Local Port: " NEW
                echo "Old: $OLD"
                echo "New: $NEW"
                read -p "Confirm (y/n): " C
                [ "$C" == "y" ] && sed -i "0,/localPort = .*/s//localPort = $NEW/" "$CONFIG_FILE"
                ;;
            5)
                OLD=$(echo "$BLOCK" | grep remotePort | sed 's/.*= //')
                read -p "New Remote Port: " NEW
                echo "Old: $OLD"
                echo "New: $NEW"
                read -p "Confirm (y/n): " C
                [ "$C" == "y" ] && sed -i "0,/remotePort = .*/s//remotePort = $NEW/" "$CONFIG_FILE"
                ;;
            0) return ;;
        esac

        read -p "Continue editing (y/n): " CONT
        [ "$CONT" != "y" ] && return
        BLOCK=$(get_proxy_block "$PNUM")
    done
}

create_proxy() {
    clear
    echo "Create New Proxy"
    echo "--------------------------------------"

    read -p "Proxy Name: " PNAME
    read -p "Type (tcp/udp/http): " PTYPE
    read -p "Local IP (default 127.0.0.1): " LIP
    LIP=${LIP:-127.0.0.1}
    read -p "Local Port: " LPORT
    read -p "Remote Port: " RPORT

    echo "" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
    echo "[[proxies]]" >> "$CONFIG_FILE"
    echo "name = \"$PNAME\"" >> "$CONFIG_FILE"
    echo "type = \"$PTYPE\"" >> "$CONFIG_FILE"
    echo "localIP = \"$LIP\"" >> "$CONFIG_FILE"
    echo "localPort = $LPORT" >> "$CONFIG_FILE"
    echo "remotePort = $RPORT" >> "$CONFIG_FILE"
}

dashboard() {
    while true; do
        clear
        ensure_login_fail

        SERVER_ADDR=$(get_value "serverAddr")
        SERVER_PORT=$(get_value "serverPort")

        echo "FRPC Dashboard"
        echo "--------------------------------------"
        echo "Server Address : ${SERVER_ADDR:-N/A}"
        echo "Server Port    : ${SERVER_PORT:-N/A}"
        echo "--------------------------------------"
        echo ""
        echo "Proxies:"
        list_proxies
        echo ""
        echo "--------------------------------------"
        echo "1) Create Proxy"
        echo "2) Edit Proxy"
        echo "3) Setup Wizard"
        echo "0) Exit"
        echo "--------------------------------------"

        read -p "Select Option: " CH

        case $CH in
            1) create_proxy ;;
            2) edit_proxy ;;
            3) setup_wizard ;;
            0) exit 0 ;;
        esac
    done
}

ensure_login_fail

if grep -q 'serverAddr = "127.0.0.1"' "$CONFIG_FILE" && \
   grep -q 'serverPort = 7000' "$CONFIG_FILE"; then
   setup_wizard
fi

dashboard
