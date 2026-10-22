#!/bin/bash
set -euo pipefail

SERVICE="lab-http.service"

echo "This will stop and disable $SERVICE and verify TCP port 8080 is closed."
read -r -p "Continue? [y/N] " ans
[[ "${ans:-}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

echo "Stopping $SERVICE"
systemctl stop "$SERVICE"
echo "Disabling $SERVICE"
systemctl disable "$SERVICE"

if ss -tulnp | grep -q ':8080'; then
  echo "FAIL: port 8080 still listening"
  exit 1
fi

echo "OK: $SERVICE stopped/disabled; port 8080 not listening"
systemctl is-enabled "$SERVICE" || true
