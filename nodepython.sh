#!/bin/bash

# Progress function
progress() {
  bar="=================================================="
  barlength=${#bar}
  percent=$1
  filled=$((percent * barlength / 100))
  empty=$((barlength - filled))

  printf "\r["
  printf "%${filled}s" | tr ' ' '='
  printf "%${empty}s" | tr ' ' ' '
  printf "] %d%%" "$percent"
}

run_step() {
  cmd=$1
  p=$2
  eval "$cmd" >/dev/null 2>&1
  progress "$p"
}

clear
echo "🚀 Installing NODEJS+PYTHON3"
echo "🚀 Please Wait"
sleep 1

# Steps
run_step "apt update -y && apt upgrade -y" 15
run_step "apt install -y python3 python3-pip python3-venv build-essential curl git" 35
run_step "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash" 55

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

run_step "nvm install 24" 75
run_step "nvm alias default 24" 85

# Permanent NVM
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo Fixing PIP
run_step "mkdir -p ~/.config/pip && echo -e \"[global]\nbreak-system-packages = true\" > ~/.config/pip/pip.conf" 95

run_step "true" 100

echo ""
echo "✅ Installation completed successfully!"
echo ""
echo "📊 Installed Versions:"
node -v
npm -v
python3 --version
pip3 --version
