sudo rm -f /usr/bin/apy 2>/dev/null

sudo tee /usr/bin/apy > /dev/null << 'EOF'
#!/bin/bash

VERSION="1.6"
LOG="$HOME/.apy.log"

GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

log(){
  echo "[$(date)] $1" >> "$LOG"
}

if [ $# -eq 0 ]; then
    echo -e "${BLUE}⚡ APY Ultra v$VERSION${RESET}"
    exit 0
fi

case "$1" in

    u)
        echo -e "${GREEN}Updating...${RESET}"
        log "Update"
        sudo apt update
        ;;

    uu)
        echo -e "${GREEN}Upgrading...${RESET}"
        log "Upgrade"
        sudo apt upgrade -y
        ;;

    r)
        shift
        echo -e "${YELLOW}Purging $@${RESET}"
        log "Purge $@"
        sudo apt purge -y "$@"
        ;;

    s)
        shift
        echo -e "${BLUE}Searching $@${RESET}"
        apt search "$@"
        ;;

    show)
        shift
        apt show "$@"
        ;;

    list)
        apt list --installed
        ;;

    clean)
        sudo apt clean
        ;;

    auto)
        sudo apt autoremove -y
        ;;

    fix)
        echo -e "${RED}Fixing broken packages...${RESET}"
        log "Fix"
        sudo apt --fix-broken install -y
        ;;

    doctor)
        echo -e "${RED}Running system repair...${RESET}"
        log "Doctor"
        sudo dpkg --configure -a
        sudo apt --fix-broken install -y
        sudo apt update
        ;;

    log)
        cat "$LOG"
        ;;

    *)
        echo -e "${GREEN}Smart install mode${RESET}"
        log "Install $@"
        sudo apt update
        sudo apt install -y "$@"
        ;;
esac
EOF

sudo chmod +x /usr/bin/apy

echo "🔥 APY Ultra v1.6 Installed Successfully!"
