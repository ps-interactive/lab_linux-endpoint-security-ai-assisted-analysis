#!/usr/bin/env bash
# Return the VM to learner-ready state.
set -euo pipefail

LAB=/opt/linux-ai-security-lab
BACKUP=/opt/instructor/telemetry-backup

echo "[reset] Restoring lab-http.service"
systemctl enable lab-http.service
systemctl restart lab-http.service

echo "[reset] Restoring synthetic telemetry"
mkdir -p "$LAB/telemetry"
rm -f "$LAB/telemetry"/*
cp -a "$BACKUP/." "$LAB/telemetry/"

echo "[reset] Clearing learner-generated sanitized and remediation files"
find "$LAB/sanitized" -mindepth 1 -delete 2>/dev/null || true
find "$LAB/remediation" -mindepth 1 -delete 2>/dev/null || true
mkdir -p "$LAB/sanitized" "$LAB/remediation"

chown -R learner:learner "$LAB" /opt/lab-services
chmod -R u+rwX,g+rX,o+rX "$LAB"

echo "[reset] Verifying lab-http"
systemctl is-active --quiet lab-http.service
ss -ltn | grep -q '127.0.0.1:8080'

echo "[reset] Complete — environment returned to learner-ready state"
