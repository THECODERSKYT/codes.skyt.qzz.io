#!/bin/bash

echo "⚡ System update..."
apt update -y && apt upgrade -y

echo "🐍 Installing Python3, pip, venv..."
apt install -y python3 python3-pip python3-venv build-essential curl git

echo "📦 Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

echo "🔄 Loading NVM..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "🚀 Installing Node.js v24..."
nvm install 24
nvm use 24
nvm alias default 24

echo "💾 Making NVM permanent..."
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
source ~/.bashrc

echo "✅ Checking versions..."
node -v
npm -v
python3 --version
pip3 --version

echo "🎉 Setup completed successfully!"
