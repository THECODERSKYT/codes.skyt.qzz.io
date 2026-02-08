#!/usr/bin/env bash

# =========================================
#   Multi-Tool By SUNNYGAMINGPE
# =========================================

# ===== COLORS =====
M='\033[1;35m'
C='\033[1;36m'
Y='\033[1;33m'
B='\033[1;34m'
R='\033[1;31m'
W='\033[1;37m'
N='\033[0m'

loading() {
  echo -ne "${C}Loading ${N}"
  for i in {1..15}; do
    echo -ne "${B}█${N}"
    sleep 0.06
  done
  echo
}

stats() {
  echo -e "${M}━━━━━━━━━━ SYSTEM STATUS ━━━━━━━━━━${N}"
  printf "${W}Host     :${N} %s\n" "$(hostname)"
  printf "${W}Uptime   :${N} %s\n" "$(uptime -p)"
  printf "${W}RAM      :${N} %s / %s\n" \
    "$(free -h | awk '/Mem:/ {print $3}')" \
    "$(free -h | awk '/Mem:/ {print $2}')"
  printf "${W}Disk     :${N} %s / %s\n" \
    "$(df -h / | awk 'NR==2 {print $3}')" \
    "$(df -h / | awk 'NR==2 {print $2}')"
  echo -e "${M}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
}

while true; do
  clear
  echo -e "${B}════════════════════════════════════${N}"
  echo -e "${Y}   ROOT Multi-Tool By SUNNYGAMINGPE${N}"
  echo -e "${B}════════════════════════════════════${N}"
  echo

  stats
  echo

  echo -e "${C}━━━━━━━━━━━━ MENU ━━━━━━━━━━━━${N}"
  echo -e "${Y}[ 1 ]${N} SSH FiX"
  echo -e "${Y}[ 2 ]${N} IDX VPS"
  echo -e "${Y}[ 3 ]${N} IDX VPS SETUP"
  echo -e "${Y}[ 4 ]${N} KVM VPS"
  echo -e "${Y}[ 5 ]${N} CodingHub"
  echo -e "${Y}[ 6 ]${N} Auto.sh Setup for IDX"
  echo -e "${Y}[ 7 ]${N} XRDP - XFCE4"
  echo -e "${Y}[ 8 ]${N} VNC - NO XFCE4"
  echo -e "${Y}[ 0 ]${N} Exit"
  echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
  echo
  echo -ne "root@SurvivalNodes~$ "
  read opt

  case "$opt" in

    6)
      clear
      echo -e "${B}Setting up Auto.sh for IDX...${N}"
      loading
      cd || exit
      cd vps123 || { echo -e "${R}vps123 not found${N}"; read; continue; }
      cat <<'EOF' > auto.sh
#!/bin/bash
printf "3\n2\n1\n" | bash <(curl -s https://vps1.jishnu.fun)
EOF
      chmod +x auto.sh
      echo -e "${C}auto.sh created successfully.${N}"
      read -p "Press ENTER to return..."
      ;;

    7)
      clear
      echo -e "${B}Installing XRDP + XFCE4...${N}"
      loading
      sudo apt update && sudo apt upgrade -y
      sudo apt install xfce4 xfce4-goodies xrdp -y
      echo "startxfce4" > ~/.xsession
      sudo chown "$(whoami)":"$(whoami)" ~/.xsession
      sudo systemctl enable xrdp
      sudo systemctl restart xrdp
      echo -e "${C}XRDP + XFCE4 ready.${N}"
      read -p "Press ENTER to return..."
      ;;

    8)
      clear
      echo -e "${B}Installing VNC (NO XFCE4)...${N}"
      loading

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
      systemctl disable start-vnc-firefox.service 2>/dev/null
      systemctl enable start-vnc-firefox.service
      systemctl start start-vnc-firefox.service

      echo -e "${C}VNC Firefox service running 24/7.${N}"
      read -p "Press ENTER to return..."
      ;;

    0)
      echo -e "${R}Exiting...${N}"
      exit 0
      ;;

    *)
      echo -e "${R}Invalid option.${N}"
      sleep 1
      ;;
  esac
done
