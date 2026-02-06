#!/usr/bin/env bash

# ===== COLORS (TPUT - WORKS EVERYWHERE) =====
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
PURPLE=$(tput setaf 5)
YELLOW=$(tput setaf 3)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
RESET=$(tput sgr0)

while true; do
clear

echo "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo "${BOLD}${WHITE}        ROOT Multi-Tool By SUNNYGAMINGPE${RESET}"
echo "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo
echo "${CYAN}━━━━━━━━━━ SYSTEM STATUS ━━━━━━━━━━${RESET}"
echo "${WHITE}Host     : $(hostname)${RESET}"
echo "${WHITE}Uptime   : $(uptime -p)${RESET}"
echo "${WHITE}RAM      : $(free -h | awk '/Mem:/ {print $3 "/" $2}')${RESET}"
echo "${WHITE}Disk     : $(df -h / | awk 'NR==2 {print $3 "/" $2}')${RESET}"
echo
echo "${BLUE}━━━━━━━━━━ MENU ━━━━━━━━━━${RESET}"
echo "${YELLOW}1) SSH Fix${RESET}"
echo "${YELLOW}2) IDX VPS${RESET}"
echo "${YELLOW}3) KVM VPS${RESET}"
echo "${YELLOW}0) Exit${RESET}"
echo
read -p "Select Option : " opt

case $opt in

1)
clear
echo "${BLUE}Applying SSH Fix...${RESET}"
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
echo "${CYAN}SSH Fix completed. Returning to menu...${RESET}"
sleep 2
;;

2)
clear
echo "${BLUE}Launching IDX VPS Tool...${RESET}"
sleep 1
bash <(curl -fsSL https://raw.githubusercontent.com/jishnu-limited/app-build-journey/refs/heads/main/vpmakerkvmidx)
echo
echo "${CYAN}Done. Returning to menu...${RESET}"
sleep 2
;;

3)
clear
echo "${BLUE}Launching KVM VPS Setup...${RESET}"
sleep 1
bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/vm/dd.sh)
bash <(curl -fsSL https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/n)
echo
echo "${CYAN}KVM VPS setup finished. Returning to menu...${RESET}"
sleep 2
;;

0)
echo "${RED}Exiting...${RESET}"
sleep 1
clear
exit
;;

*)
echo "${RED}Invalid option!${RESET}"
sleep 1
;;

esac
done
