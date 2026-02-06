#!/bin/bash

# ===== COLORS (NO GREEN) =====
RED='\033[1;31m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
RESET='\033[0m'

clear

while true; do
clear

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${WHITE}        ROOT Multi-Tool By SUNNYGAMINGPE${RESET}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo
echo -e "${CYAN}━━━━━━━━━━ SYSTEM STATUS ━━━━━━━━━━${RESET}"
echo -e "${WHITE}Host     : $(hostname)${RESET}"
echo -e "${WHITE}Uptime   : $(uptime -p)${RESET}"
echo -e "${WHITE}RAM      : $(free -h | awk '/Mem:/ {print $3 "/" $2}')${RESET}"
echo -e "${WHITE}Disk     : $(df -h / | awk 'NR==2 {print $3 "/" $2}')${RESET}"
echo
echo -e "${BLUE}━━━━━━━━━━ MENU ━━━━━━━━━━${RESET}"
echo -e "${YELLOW}1) SSH Fix${RESET}"
echo -e "${YELLOW}2) IDX VPS${RESET}"
echo -e "${YELLOW}3) KVM VPS${RESET}"
echo -e "${YELLOW}0) Exit${RESET}"
echo
read -p "Select Option : " opt

case $opt in

1)
clear
echo -e "${BLUE}Running SSH Fix...${RESET}"
sleep 1

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

echo
echo -e "${CYAN}SSH Fix Completed. Returning to menu...${RESET}"
sleep 2
;;

2)
clear
echo -e "${BLUE}Launching IDX VPS Tool...${RESET}"
sleep 1
bash <(curl -fsSL https://raw.githubusercontent.com/jishnu-limited/app-build-journey/refs/heads/main/vpmakerkvmidx)
echo
echo -e "${CYAN}Task Finished. Returning to menu...${RESET}"
sleep 2
;;

3)
clear
echo -e "${BLUE}Launching KVM VPS Setup...${RESET}"
sleep 1
bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/vm/dd.sh)
bash <(curl -fsSL https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/n)
echo
echo -e "${CYAN}KVM VPS Setup Done. Returning to menu...${RESET}"
sleep 2
;;

0)
echo -e "${RED}Exiting Tool...${RESET}"
sleep 1
clear
exit
;;

*)
echo -e "${RED}Invalid option! Try again...${RESET}"
sleep 1
;;

esac
done
