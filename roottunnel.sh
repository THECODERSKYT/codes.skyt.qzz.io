#!/bin/bash

BASE="/var/www/.roottunnel"
BIN="$BASE/bin"
CONF="$BASE/.data"
CONFIG_FILE="$CONF/.sys"
INSTALLED="$BASE/.installed"
SYSTEMD_MARK="$BASE/.systemd"

SERVICE_NAME="frpc-root-tunnel.service"

mkdir -p "$BIN" "$CONF"

H1="NDUuNTkuMTMyLjE1Ng=="
H2="NzAwMA=="
H3="c2t5dDExMDA="

ADDR=$(echo "$H1" | base64 -d)
PORT=$(echo "$H2" | base64 -d)
TOKEN=$(echo "$H3" | base64 -d)

loading(){
for i in {1..25}; do
printf "\e[1;36m#\e[0m"
sleep 0.03
done
echo ""
}

install_rt(){

LATEST=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | cut -d '"' -f4 | sed 's/v//')

if [ -f "$INSTALLED" ]; then
VER=$(cat "$INSTALLED")
[ "$VER" = "$LATEST" ] && return
fi

echo -e "\e[1;32mInstalling Root-Tunnel...\e[0m"
loading

URL="https://github.com/fatedier/frp/releases/download/v${LATEST}/frp_${LATEST}_linux_amd64.tar.gz"

TMP=$(mktemp -d)

wget -q -O "$TMP/frp.tar.gz" "$URL"
tar -xzf "$TMP/frp.tar.gz" -C "$TMP"

DIR=$(ls "$TMP" | grep frp_)
cp "$TMP/$DIR/frpc" "$BIN/"

chmod +x "$BIN/frpc"

rm -rf "$TMP"

echo "$LATEST" > "$INSTALLED"

echo -e "\e[1;92mRoot-Tunnel 1.2 beta installed successfully\e[0m"

}

ensure_config(){

if [ ! -f "$CONFIG_FILE" ]; then

cat > "$CONFIG_FILE" <<EOF
loginFailExit = false
serverAddr = "$ADDR"
serverPort = $PORT
auth.method = "token"
auth.token = "$TOKEN"
EOF

fi

}

generate_port(){

while true; do

P=$(( RANDOM % (65535-5000+1) + 5000 ))

USED=$(grep "^remotePort" "$CONFIG_FILE" 2>/dev/null | awk '{print $3}')

if ! echo "$USED" | grep -q "^$P$"; then
echo "$P"
return
fi

done

}

generate_name(){

tr -dc 'a-z0-9' </dev/urandom | head -c 20

}

list_proxies(){

awk '/\[\[proxies\]\]/{c++;print c") Proxy";next} c>0 && NF{print "   "$0}' "$CONFIG_FILE"

}

get_proxy_range(){

awk -v n="$1" '/\[\[proxies\]\]/{c++} c==n{start=NR} c==n+1{end=NR-1} END{if(start && !end) end=NR; if(start) print start":"end}' "$CONFIG_FILE"

}

create_proxy(){

clear
echo -e "\e[1;33mCreate Proxy\e[0m"

PNAME=$(generate_name)

echo -e "\e[1;36mGenerated Proxy Name: $PNAME\e[0m"

read -p "Type (tcp/udp/http): " PTYPE
read -p "Local IP (default 127.0.0.1): " LIP
LIP=${LIP:-127.0.0.1}
read -p "Local Port: " LPORT

RPORT=$(generate_port)

echo -e "\e[1;36mAssigned Remote Port: $RPORT\e[0m"

cat >> "$CONFIG_FILE" <<EOF


[[proxies]]
name = "$PNAME"
type = "$PTYPE"
localIP = "$LIP"
localPort = $LPORT
remotePort = $RPORT
EOF

read -p "Proxy created. Press Enter..."

}

delete_proxy(){

clear
echo -e "\e[1;31mDelete Proxy\e[0m"

list_proxies

read -p "Select Proxy Number to delete: " PNUM

START=$(grep -n "\[\[proxies\]\]" "$CONFIG_FILE" | sed -n "${PNUM}p" | cut -d: -f1)

[ -z "$START" ] && return

NEXT=$(grep -n "\[\[proxies\]\]" "$CONFIG_FILE" | sed -n "$((PNUM+1))p" | cut -d: -f1)

if [ -z "$NEXT" ]; then
END='$'
else
END=$((NEXT-1))
fi

echo ""
sed -n "${START},${END}p" "$CONFIG_FILE"

echo ""
read -p "Are you sure you want to delete this proxy? (y/n): " CONFIRM

if [[ "$CONFIRM" == "y" ]]; then

sed -i "${START},${END}d" "$CONFIG_FILE"

echo -e "\e[1;32mProxy deleted successfully\e[0m"

else

echo -e "\e[1;33mCancelled\e[0m"

fi

read -p "Press Enter..."

}

edit_proxy(){

clear
echo -e "\e[1;33mEdit Proxy\e[0m"

list_proxies

read -p "Select Proxy Number: " PNUM

RANGE=$(get_proxy_range "$PNUM")

[ -z "$RANGE" ] && return

START=$(echo $RANGE | cut -d: -f1)
END=$(echo $RANGE | cut -d: -f2)

while true; do

clear

sed -n "${START},${END}p" "$CONFIG_FILE"

echo ""

echo "1) Name"
echo "2) Type"
echo "3) Local IP"
echo "4) Local Port"
echo "0) Back"

read -p "Select: " OPT

case $OPT in
1) FIELD="name"; Q="yes" ;;
2) FIELD="type"; Q="yes" ;;
3) FIELD="localIP"; Q="yes" ;;
4) FIELD="localPort"; Q="no" ;;
0) return ;;
*) continue ;;
esac

read -p "New value: " NEW

if [ "$Q" = "yes" ]; then
sed -i "${START},${END}s/^$FIELD.*/$FIELD = \"$NEW\"/" "$CONFIG_FILE"
else
sed -i "${START},${END}s/^$FIELD.*/$FIELD = $NEW/" "$CONFIG_FILE"
fi

done

}

restart_tunnel(){

if command -v systemctl >/dev/null 2>&1; then

SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

if [ ! -f "$SYSTEMD_MARK" ]; then

cat <<EOF > "$SERVICE_PATH"
[Unit]
Description=Root-Tunnel Client
After=network.target

[Service]
Type=simple
ExecStart=$BIN/frpc -c $CONFIG_FILE
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "$SERVICE_NAME" >/dev/null 2>&1

touch "$SYSTEMD_MARK"

fi

systemctl restart "$SERVICE_NAME"

echo -e "\e[1;32mTunnel restarted using systemd\e[0m"

else

echo -e "\e[1;31mSystemd not available\e[0m"

fi

read -p "Press Enter..."

}

run_nohup(){

nohup "$BIN/frpc" -c "$CONFIG_FILE" >/dev/null 2>&1 &

echo -e "\e[1;32mTunnel Started in background Using nohup \e[0m"

read -p "Press Enter..."

}

dashboard(){

while true; do

clear

echo -e "\e[1;95m====================================\e[0m"
echo -e "\e[1;96m           Root-Tunnel\e[0m"
echo -e "\e[1;93m    Made By ROOT@SUNNY SUNNYGAMINGPE\e[0m"
echo -e "\e[1;95m====================================\e[0m"

echo ""
echo -e "\e[1;94mServer IP : $ADDR\e[0m"
echo -e "\e[1;32mConfigured Proxies:\e[0m"

list_proxies

echo ""

echo -e "\e[1;95m------------------------------------\e[0m"

echo "1) Create Proxy"
echo "2) Edit Proxy"
echo "3) Delete Proxy"
echo "4) Start Restart Tunnel"
echo "5) Run Tunnel (Not Recommended)"
echo "0) Exit"

echo -e "\e[1;95m------------------------------------\e[0m"

read -p "Select Option: " CH

case $CH in

1) create_proxy ;;
2) edit_proxy ;;
3) delete_proxy ;;
4) restart_tunnel ;;
5) run_nohup ;;
0) exit ;;

esac

done

}

install_rt
ensure_config
dashboard
