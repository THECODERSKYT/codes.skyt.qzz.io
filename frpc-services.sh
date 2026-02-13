#!/bin/bash

FRP_PATH="/root/frp"

echo "Creating FRPC systemd service..."

cat <<EOF > /etc/systemd/system/frpc.service
[Unit]
Description=FRP Client Service
After=network.target

[Service]
Type=simple
ExecStart=$FRP_PATH/frpc -c $FRP_PATH/frpc.toml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
systemctl daemon-reload

echo "Enabling FRPC service..."
systemctl enable frpc

echo "Starting FRPC service..."
systemctl start frpc

echo "Done ✅"
echo "Service Status:"
systemctl status frpc --no-pager
