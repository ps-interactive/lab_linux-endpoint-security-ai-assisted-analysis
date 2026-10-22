#!/usr/bin/env bash
# Instructor reference only — do not place in learner workspace.
set -euo pipefail

echo "This script will stop and disable lab-http.service and verify port 8080 is closed."
read -r -p "Continue? [y/N] " ans
[[ "${ans:-}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

systemctl stop lab-http.service
systemctl disable lab-http.service
systemctl status lab-http.service --no-pager || true

if ss -tulnp | grep -q ':8080'; then
  echo "FAIL: port 8080 still listening"
  exit 1
fi

echo "OK: lab-http.service stopped/disabled; port 8080 not listening"
systemctl is-enabled lab-http.service || true
