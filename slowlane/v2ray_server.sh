#!/bin/bash

set -e

LOGFILE="/var/log/v2ray-install.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "🔧 Updating system..."
#apt update && apt upgrade -y

echo "📦 Installing required packages..."
apt install -y curl unzip uuid-runtime

echo "⬇️ Downloading and installing V2Ray..."
bash <(curl -L -s https://github.com/v2fly/fhs-install-v2ray/raw/master/install-release.sh)

echo "📁 Creating log directory..."
mkdir -p /var/log/v2ray
touch /var/log/v2ray/access.log
touch /var/log/v2ray/error.log
chown -R nobody:nogroup /var/log/v2ray

echo "🔐 Generating UUID..."
UUID=$(uuidgen)
echo "Generated UUID: $UUID"

echo "⚙️ Writing V2Ray config..."
CONFIG_PATH="/usr/local/etc/v2ray/config.json"

cat > "$CONFIG_PATH" <<EOF
{
  "log": {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [{
    "port": 10086,
    "protocol": "vmess",
    "settings": {
      "clients": [{
        "id": "$UUID",
        "alterId": 0
      }]
    },
    "streamSettings": {
      "network": "tcp"
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
EOF

echo "✅ Config file written to: $CONFIG_PATH"

echo "🔄 Enabling and starting V2Ray service..."
systemctl enable v2ray
systemctl restart v2ray

echo "🔍 Checking V2Ray service status..."
systemctl status v2ray --no-pager

echo "Enter Your server IP:"
read YOUR_SERVER_IP

echo "✅ V2Ray setup completed!"
echo "==============================="
echo "🔑 VMess Connection Details:"
echo "Address: $YOUR_SERVER_IP"
echo "Port: 10086"
echo "UUID: $UUID"
echo "AlterID: 0"
echo "Network: TCP"
echo "Security: auto"
echo "==============================="
echo "📄 Logs:"
echo "- Access Log: /var/log/v2ray/access.log"
echo "- Error Log:  /var/log/v2ray/error.log"
echo "- Install Log: $LOGFILE"
echo "==============================="
