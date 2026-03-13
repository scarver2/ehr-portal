#!/usr/bin/env bash
# Usage: 
#   scp bin/vps_bootstrap.sh root@45.76.237.124:/root/
#   ssh root@45.76.237.124
#   bash vps_bootstrap.sh

set -euo pipefail

echo "== Updating system packages =="
apt update
apt upgrade -y

echo "== Installing base utilities =="
apt install -y \
  git \
  curl \
  vim \
  htop \
  fail2ban \
  ufw

echo "== Configuring firewall =="
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw --force enable

echo "== Creating deploy user (if missing) =="
if ! id "deploy" &>/dev/null; then
  adduser --disabled-password --gecos "" deploy
  usermod -aG sudo deploy
fi

echo "== Setup complete =="
