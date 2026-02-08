#!/bin/bash

# ================= COLORS =================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
WHITE="\e[97m"
RESET="\e[0m"
BOLD="\e[1m"

# ================= LOOP =================
while true; do
clear

echo -e "${BOLD}${CYAN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "        ROOT Multi-Tool By SUNNYGAMINGPE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${RESET}"

echo -e "${WHITE}Credits = @Jishnu @CodingHub @B1${RESET}"
echo

echo -e "${YELLOW}━━━━━━━━━━ SYSTEM STATUS ━━━━━━━━━━${RESET}"
echo -e "${CYAN}Host   : r-rootskyt-vm-4cbr93gs-c1f18-q6dg9${RESET}"
echo -e "${CYAN}Uptime : $(uptime -p)${RESET}"
echo -e "${CYAN}RAM    : $(free -h | awk '/Mem:/ {print $3 "/" $2}')${RESET}"
echo -e "${CYAN}Disk   : $(df -h / | awk 'NR==2 {print $3 "/" $2}')${RESET}"
echo

echo -e "${BOLD}${BLUE}━━━━━━━━━━ MENU ━━━━━━━━━━${RESET}"
echo -e "${GREEN}1) SSH FIX${RESET}"
echo -e "${GREEN}2) IDX VPS${RESET}"
echo -e "${GREEN}3) KVM VPS${RESET}"
echo -e "${GREEN}4) CodingHub${RESET}"
echo -e "${GREEN}5) Auto.sh setup for IDX${RESET}"
echo -e "${GREEN}6) XRDP-XFCE4${RESET}"
echo -e "${GREEN}7) VNC-NO-XFCE4${RESET}"
echo -e "${RED}0) Exit${RESET}"
echo

read -p "Select option : " opt

case "$opt" in

1)
echo -e "${YELLOW}Running SSH FIX...${RESET}"
sudo bash -c 'cat <<EOF > /etc/ssh/sshd_config
PasswordAuthentication yes
PermitRootLogin yes
PubkeyAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
Subsystem sftp /usr/lib/openssh/sftp-server
EOF'
systemctl restart ssh 2>/dev/null || service ssh restart
passwd root
;;

2)
echo -e "${YELLOW}Running IDX VPS...${RESET}"
bash <(curl -s https://raw.githubusercontent.com/jishnu-limited/app-build-journey/refs/heads/main/vpmakerkvmidx)
;;

3)
echo -e "${YELLOW}Running KVM VPS...${RESET}"
bash <(curl -s https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/vm/dd.sh)
bash <(curl -s https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/n)
;;

4)
echo -e "${YELLOW}Running CodingHub...${RESET}"
bash <(curl -s https://ptero.nobitapro.online)
;;

5)
echo -e "${YELLOW}Setting up auto.sh for IDX...${RESET}"
cd ~ || exit
mkdir -p vps123
cd vps123 || exit

cat <<'EOF' > auto.sh
#!/bin/bash
printf "3\n2\n1\n" | bash <(curl -s https://vps1.jishnu.fun)
EOF

chmod +x auto.sh
echo -e "${GREEN}auto.sh created inside vps123${RESET}"
;;

6)
echo -e "${YELLOW}Installing XRDP + XFCE4...${RESET}"
sudo apt update && sudo apt upgrade -y
sudo apt install xfce4 xfce4-goodies xrdp -y
echo "startxfce4" > ~/.xsession
sudo chown $(whoami):$(whoami) ~/.xsession
sudo systemctl enable xrdp
sudo systemctl restart xrdp
;;

7)
echo -e "${YELLOW}Installing VNC without XFCE4...${RESET}"
apt update && apt install tightvncserver firefox-esr -y

cat <<'EOF' > /root/start-vnc-firefox.sh
#!/bin/bash
vncserver :1
export DISPLAY=:1
sleep 2
firefox &
echo "VNC :1 started and Firefox launched"
EOF

chmod +x /root/start-vnc-firefox.sh

cat <<'EOF' > /etc/systemd/system/start-vnc-firefox.service
[Unit]
Description=Start VNC Firefox 24/7
After=network.target

[Service]
Type=oneshot
User=root
WorkingDirectory=/root
ExecStart=/bin/bash /root/start-vnc-firefox.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl disable start-vnc-firefox.service
systemctl enable start-vnc-firefox.service
systemctl start start-vnc-firefox.service
;;

0)
echo -e "${RED}Exiting...${RESET}"
exit 0
;;

*)
echo -e "${RED}Invalid option! Please choose correctly.${RESET}"
sleep 2
;;

esac

echo
read -p "Press Enter to return to menu..."
done
