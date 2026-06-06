#!/bin/bash
set -e

SERVER_HOST="${SERVER_HOST:-your-server-ip}"
SERVER_USER="${SERVER_USER:-root}"
APP_DIR="/opt/projectm"

echo "Deploying to $SERVER_USER@$SERVER_HOST..."

ssh "$SERVER_USER@$SERVER_HOST" << 'EOF'
  set -e
  cd /opt/projectm
  git pull origin main
  cd Server
  swift build -c release 2>&1
  sudo systemctl restart projectm
  echo "Deploy complete."
EOF
