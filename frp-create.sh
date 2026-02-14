#!/bin/bash

CONFIG_FILE="frp/frpc.toml"

clear

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

get_value() {
    grep -E "^$1" "$CONFIG_FILE" | head -n1 | sed -E 's/.*=\s*"?([^"]*)"?/\1/' 2>/dev/null
}

SERVER_ADDR=$(get_value "serverAddr")
SERVER_PORT=$(get_value "serverPort")
AUTH_METHOD=$(get_value "auth.method")
AUTH_TOKEN=$(get_value "auth.token")

[ -z "$SERVER_ADDR" ] && SERVER_ADDR="N/A"
[ -z "$SERVER_PORT" ] && SERVER_PORT="N/A"
[ -z "$AUTH_METHOD" ] && AUTH_METHOD="N/A"
[ -z "$AUTH_TOKEN" ] && AUTH_TOKEN="N/A"

echo "---------------------------------------------"
echo "              FRPC Dashboard"
echo "---------------------------------------------"
echo "Server Address : $SERVER_ADDR"
echo "Server Port    : $SERVER_PORT"
echo "Auth Method    : $AUTH_METHOD"
echo "Auth Token     : $AUTH_TOKEN"
echo "---------------------------------------------"
echo ""
echo "Configured Proxies:"
echo ""

awk '
/\[\[proxies\]\]/ {proxy=1; print "---------------------------------"}
proxy==1 {print}
/^$/ {proxy=0}
' "$CONFIG_FILE"

echo ""
echo "---------------------------------------------"
echo "1) Create New Proxy"
echo "2) Exit"
echo "---------------------------------------------"
read -p "Select Option: " OPTION

if [ "$OPTION" == "1" ]; then

    echo ""
    read -p "Proxy Name: " PNAME

    read -p "Type (tcp/udp/http): " PTYPE

    read -p "Local IP (default 127.0.0.1): " LIP
    LIP=${LIP:-127.0.0.1}

    read -p "Local Port: " LPORT
    read -p "Remote Port: " RPORT

    echo "" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"

    echo "[[proxies]]" >> "$CONFIG_FILE"
    echo "name = \"$PNAME\"" >> "$CONFIG_FILE"
    echo "type = \"$PTYPE\"" >> "$CONFIG_FILE"
    echo "localIP = \"$LIP\"" >> "$CONFIG_FILE"
    echo "localPort = $LPORT" >> "$CONFIG_FILE"
    echo "remotePort = $RPORT" >> "$CONFIG_FILE"

    echo ""
    echo "New proxy added successfully."
fi
