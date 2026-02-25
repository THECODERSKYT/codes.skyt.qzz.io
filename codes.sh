#!/usr/bin/env bash

# =========================================
#   Multi-Tool By SUNNYGAMINGPE
# =========================================

# ===== STRONG COLORS =====
M='\033[1;35m'   # Magenta
C='\033[1;36m'   # Cyan
Y='\033[1;33m'   # Yellow
B='\033[1;34m'   # Blue
R='\033[1;31m'   # Red
W='\033[1;37m'   # White
N='\033[0m'      # Reset

# Loading bar
loading() {
  echo -ne "${C}Loading ${N}"
  for i in {1..15}; do
    echo -ne "${B}█${N}"
    sleep 0.06
  done
  echo
}

# System statistics
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
  echo -e "${Y}[ 1 ]${N} SSH FiX            ${Y}[ 11 ]${N} ROOTPORT"
  echo -e "${Y}[ 2 ]${N} IDX VPS            ${Y}[ 12 ]${N} NodeJS+Python3"
  echo -e "${Y}[ 3 ]${N} IDX VPS SETUP"
  echo -e "${Y}[ 4 ]${N} NON-KVM VPS"
  echo -e "${Y}[ 5 ]${N} CodingHub"
  echo -e "${Y}[ 6 ]${N} Auto.sh Setup for IDX"
  echo -e "${Y}[ 7 ]${N} XRDP - XFCE4"
  echo -e "${Y}[ 8 ]${N} FRP Installer Updater"
  echo -e "${Y}[ 9 ]${N} FRP-Services"
  echo -e "${Y}[ 10 ]${N} FRP Manager"
  echo -e "${Y}[ 0 ]${N} Exit"
  echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
  echo
  echo -ne "root@SurvivalNodes~$ "
  read opt

  case "$opt" in

    1)
      clear
      echo -e "${B}Applying SSH FiX...${N}"
      loading
      sudo bash -c 'cat <<EOF > /etc/ssh/sshd_config
PasswordAuthentication yes
PermitRootLogin yes
PubkeyAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
systemctl restart ssh 2>/dev/null || service ssh restart
passwd root
'
      echo -e "${C}SSH FiX completed.${N}"
      read -p "Press ENTER to return..."
      ;;

    2)
      clear
      echo -e "${B}Running IDX VPS...${N}"
      loading
      bash <(curl -fsSL https://raw.githubusercontent.com/jishnu-limited/app-build-journey/refs/heads/main/vpmakerkvmidx)
      echo -e "${C}IDX VPS completed.${N}"
      read -p "Press ENTER to return..."
      ;;

    3)
      clear
      echo -e "${B}Running IDX VPS SETUP...${N}"
      loading
      cd || exit
      rm -rf myapp flutter
      cd vps123 || { echo -e "${R}vps123 directory not found.${N}"; read; continue; }
      mkdir -p .idx
      cd .idx || exit
      cat <<'EOF' > dev.nix
{ pkgs, ... }: {
  channel = "stable-24.05";
  packages = with pkgs; [
    unzip openssh git qemu_kvm sudo cdrkit cloud-utils qemu nano curl
  ];
  env = { EDITOR = "nano"; };
  idx = {
    extensions = [ "Dart-Code.flutter" "Dart-Code.dart-code" ];
    workspace = {
      onCreate = { };
      onStart = {
        autoRun = ''
          echo "Running auto.sh..."
          chmod +x ./auto.sh
          ./auto.sh
        '';
      };
    };
    previews = { enable = false; };
  };
}
EOF
      echo -e "${C}IDX VPS SETUP completed.${N}"
      read -p "Press ENTER to return..."
      ;;

    4)
      clear
      echo -e "${B}Starting NON-KVM VPS setup...${N}"
      loading
      bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/vm/dd.sh)
      loading
      bash <(curl -fsSL https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/n)
      echo -e "${C}KVM VPS setup completed.${N}"
      read -p "Press ENTER to return..."
      ;;

    5)
      clear
      echo -e "${B}Running CodingHub...${N}"
      loading
      bash <(curl -s https://ptero.nobitapro.online)
      echo -e "${C}CodingHub completed.${N}"
      read -p "Press ENTER to return..."
      ;;

    6)
      clear
      echo -e "${B}Setting up Auto.sh for IDX...${N}"
      loading
      cd || exit
      cd vps123 || { echo -e "${R}vps123 directory not found.${N}"; read; continue; }
      cat <<'EOF' > auto.sh
#!/bin/bash
printf "3\n2\n1\n" | bash <(curl -s https://vps1.jishnu.fun)
EOF
      chmod +x auto.sh
      echo -e "${C}auto.sh created in vps123.${N}"
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
      echo -e "${C}XRDP + XFCE4 setup completed.${N}"
      read -p "Press ENTER to return..."
      ;;

    8)
      clear
      echo -e "${M}Launching FRP Installer Updater${N}"
      loading
      bash <(curl -fsSL https://raw.githubusercontent.com/THECODERSKYT/codes.skyt.qzz.io/refs/heads/main/frp.sh)
      echo -e "${C}FRP Installer Updater completed.${N}"
      read -p "Press ENTER to return..."
      ;;

    9)
      clear
      echo -e "${M}Launching FRP-Services${N}"
      loading
      bash <(curl -fsSL https://raw.githubusercontent.com/THECODERSKYT/codes.skyt.qzz.io/refs/heads/main/frpc-services.sh)
      echo -e "${C}FRP-Services completed.${N}"
      read -p "Press ENTER to return..."
      ;;

    10)
      clear
      echo -e "${M}Launching FRP Manager${N}"
      loading
      bash <(curl -fsSL https://raw.githubusercontent.com/THECODERSKYT/codes.skyt.qzz.io/refs/heads/main/frp-create.sh)
      echo -e "${C}FRP Manage completed.${N}"
      read -p "Press ENTER to return..."
      ;;

    11)
      clear
      echo -e "${M}Launching ROOTPORT${N}"
      loading
      bash <(curl -s https://ports.skyt.qzz.io)
      echo -e "${C}ROOTPORT completed.${N}"
      read -p "Press ENTER to return..."
      ;;

    12)
      clear
      echo -e "${M}Installing NodeJS + Python3...${N}"
      loading
      bash <(curl -fsSL https://raw.githubusercontent.com/THECODERSKYT/codes.skyt.qzz.io/refs/heads/main/nodepython.sh)
      echo -e "${C}NodeJS + Python3 setup completed.${N}"
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
