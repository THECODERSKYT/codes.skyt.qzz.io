#!/usr/bin/env bash

# =========================================
#   Multi-Tool By SUNNYGAMINGPE
# =========================================

# Minimal colors (no green, no emoji style)
M='\033[1;35m'
C='\033[1;36m'
Y='\033[1;33m'
R='\033[1;31m'
N='\033[0m'

# Loading bar
loading() {
  echo -ne "Loading "
  for i in {1..12}; do
    echo -ne "█"
    sleep 0.07
  done
  echo
}

# System statistics (clean & aligned, no emoji)
stats() {
  echo "━━━━━━━━━━ SYSTEM STATUS ━━━━━━━━━━"
  printf "Host     : %s\n" "$(hostname)"
  printf "Uptime   : %s\n" "$(uptime -p)"
  printf "RAM      : %s / %s\n" \
    "$(free -h | awk '/Mem:/ {print $3}')" \
    "$(free -h | awk '/Mem:/ {print $2}')"
  printf "Disk     : %s / %s\n" \
    "$(df -h / | awk 'NR==2 {print $3}')" \
    "$(df -h / | awk 'NR==2 {print $2}')"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

while true; do
  clear

  echo -e "${M}Multi-Tool By SUNNYGAMINGPE${N}"
  echo

  stats
  echo

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "[ 1 ] SSH FiX"
  echo "[ 2 ] IDX VPS"
  echo "[ 3 ] IDX VPS SETUP"
  echo "[ 4 ] KVM VPS"
  echo "[ 0 ] Exit"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo -ne "root@SurvivalNodes~$ "
  read opt

  case "$opt" in

    1)
      clear
      echo "Applying SSH FiX..."
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
      echo "SSH FiX completed."
      read -p "Press ENTER to return..."
      ;;

    2)
      clear
      echo "Running IDX VPS..."
      loading
      bash <(curl -fsSL https://raw.githubusercontent.com/jishnu-limited/app-build-journey/refs/heads/main/vpmakerkvmidx)
      echo "IDX VPS completed."
      read -p "Press ENTER to return..."
      ;;

    3)
      clear
      echo "Running IDX VPS SETUP..."
      loading

      cd || exit
      rm -rf myapp flutter

      cd vps123 || { echo "vps123 directory not found."; read; continue; }

      mkdir -p .idx
      cd .idx || exit

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

      echo "IDX VPS SETUP completed."
      read -p "Press ENTER to return..."
      ;;

    4)
      clear
      echo "Starting KVM VPS setup..."
      loading

      bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/vm/dd.sh)

      echo "First KVM script completed."
      loading

      bash <(curl -fsSL https://raw.githubusercontent.com/JishnuTheGamer/Vps/refs/heads/main/n)

      echo "KVM VPS setup completed."
      read -p "Press ENTER to return..."
      ;;

    0)
      echo "Exiting..."
      exit 0
      ;;

    *)
      echo "Invalid option."
      sleep 1
      ;;
  esac
done
