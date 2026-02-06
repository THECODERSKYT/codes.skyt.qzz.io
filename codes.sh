#!/usr/bin/env bash

# =========================================
#   ROOT Multi-Tool By SUNNYGAMINGPE
# =========================================

# Colors
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
C='\033[1;36m'
M='\033[1;35m'
N='\033[0m'

# Loading bar
loading() {
  echo -ne "${C}Loading"
  for i in {1..10}; do
    echo -ne "█"
    sleep 0.08
  done
  echo -e "${N}"
}

# System stats
stats() {
  echo -e "${Y}━━━━━━━━━━ SYSTEM STATUS ━━━━━━━━━━${N}"
  echo -e "${G}🖥  Host     :$(hostname)${N}"
  echo -e "${G}⏱  Uptime   :$(uptime -p)${N}"
  echo -e "${G}💾 RAM      :$(free -h | awk '/Mem:/ {print $3 "/" $2}')${N}"
  echo -e "${G}📦 Disk     :$(df -h / | awk 'NR==2 {print $3 "/" $2}')${N}"
  echo -e "${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
}

while true; do
  clear

  echo -e "${M}"
  echo "██████╗  ██████╗  ██████╗ ████████╗"
  echo "██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝"
  echo "██████╔╝██║   ██║██║   ██║   ██║   "
  echo "██╔══██╗██║   ██║██║   ██║   ██║   "
  echo "██║  ██║╚██████╔╝╚██████╔╝   ██║   "
  echo "╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   "
  echo -e "${C}ROOT Multi-Tool By SUNNYGAMINGPE${N}"
  echo

  stats
  echo

  echo -e "${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
  echo -e "${G}[ 1 ] SSH FiX${N}"
  echo -e "${C}[ 2 ] IDX VPS${N}"
  echo -e "${M}[ 3 ] IDX VPS SETUP${N}"
  echo -e "${R}[ 0 ] Exit${N}"
  echo -e "${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
  echo

  echo -ne "${G}root@SurvivalNodes~$ ${N}"
  read opt

  case "$opt" in

    1)
      clear
      echo -e "${C}🔧 Applying SSH FiX...${N}"
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
      echo -e "${G}✅ SSH FiX Done${N}"
      read -p "Press ENTER to return..."
      ;;

    2)
      clear
      echo -e "${C}🚀 Running IDX VPS Script...${N}"
      loading
      bash <(curl -fsSL https://raw.githubusercontent.com/jishnu-limited/app-build-journey/refs/heads/main/vpmakerkvmidx)
      echo -e "${G}✅ IDX VPS Completed${N}"
      read -p "Press ENTER to return..."
      ;;

    3)
      clear
      echo -e "${Y}🧹 Cleaning up old files...${N}"
      loading

      cd || exit
      rm -rf myapp flutter

      cd vps123 || { echo -e "${R}❌ vps123 not found${N}"; read; continue; }

      if [ ! -d ".idx" ]; then
        echo -e "${G}📁 Creating .idx directory...${N}"
        mkdir .idx
      fi

      cd .idx || exit

      echo -e "${C}📄 Creating dev.nix...${N}"

      cat <<'EOF' > dev.nix
{ pkgs, ... }: {
  channel = "stable-24.05";

  packages = with pkgs; [
    unzip
    openssh
    git
    qemu_kvm
    sudo
    cdrkit
    cloud-utils
    qemu
    nano
    curl
  ];

  env = {
    EDITOR = "nano";
  };

  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];

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

    previews = {
      enable = false;
    };
  };
}
EOF

      echo -e "${G}✅ IDX VPS SETUP Completed Successfully${N}"
      read -p "Press ENTER to return..."
      ;;

    0)
      echo -e "${Y}👋 Exiting...${N}"
      exit 0
      ;;

    *)
      echo -e "${R}❌ Invalid Option${N}"
      sleep 1
      ;;
  esac
done
