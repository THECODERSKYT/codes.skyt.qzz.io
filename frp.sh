#!/bin/bash
set -e

LATEST=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | cut -d '"' -f4 | sed 's/v//')
URL="https://github.com/fatedier/frp/releases/download/v${LATEST}/frp_${LATEST}_linux_amd64.tar.gz"

mkdir -p frp_backup
[ -f frp/frpc.toml ] && cp frp/frpc.toml frp_backup/
[ -f frp/frps.toml ] && cp frp/frps.toml frp_backup/

wget -O frp.tar.gz "$URL"
rm -rf frp && mkdir frp
tar -xzf frp.tar.gz -C frp --strip-components=1

[ -f frp_backup/frpc.toml ] && cp frp_backup/frpc.toml frp/
[ -f frp_backup/frps.toml ] && cp frp_backup/frps.toml frp/

rm frp.tar.gz
echo "FRP Installed Or Updated"
