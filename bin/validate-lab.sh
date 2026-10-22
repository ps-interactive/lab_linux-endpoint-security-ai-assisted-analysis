#!/usr/bin/env bash
# sudo /usr/local/sbin/validate-lab.sh
set -u
PASS=0
FAIL=0

pass() { echo "[PASS] $*"; PASS=$((PASS+1)); }
fail() { echo "[FAIL] $*"; FAIL=$((FAIL+1)); }

echo "=== Linux AI Security Lab Validation ==="

if grep -qi ubuntu /etc/os-release; then
  pass "Ubuntu/Linux version ($(. /etc/os-release; echo $PRETTY_NAME))"
else
  fail "Ubuntu/Linux version"
fi

if id learner >/dev/null 2>&1; then pass "learner account"; else fail "learner account"; fi

for cmd in bash ps ss ip grep sed cat journalctl systemctl curl wget jq nano vim python3; do
  if command -v "$cmd" >/dev/null 2>&1; then pass "$cmd"; else fail "$cmd"; fi
done

LAB=/opt/linux-ai-security-lab
if [[ -d "$LAB" ]]; then pass "Lab root $LAB"; else fail "Lab root $LAB"; fi
for d in telemetry sanitized prompts remediation; do
  if [[ -d "$LAB/$d" ]]; then pass "Directory $d"; else fail "Directory $d"; fi
done
if [[ -f "$LAB/telemetry/auth-sample.log" && -f "$LAB/telemetry/syslog-sample.log" ]]; then
  pass "Lab telemetry"
else
  fail "Lab telemetry"
fi
if [[ -f "$LAB/prompts/anomaly-analysis.txt" ]]; then pass "Prompt files"; else fail "Prompt files"; fi

if [[ -f /etc/systemd/system/lab-http.service ]]; then pass "lab-http.service unit"; else fail "lab-http.service unit"; fi
if systemctl is-active --quiet lab-http.service; then pass "Lab HTTP service"; else fail "Lab HTTP service"; fi
if ss -ltn | grep -q '127.0.0.1:8080'; then pass "Port 8080"; else fail "Port 8080"; fi

if sudo -u learner test -r "$LAB/README.txt"; then pass "learner can access lab files"; else fail "learner can access lab files"; fi

echo "=== Summary: $PASS passed, $FAIL failed ==="
if [[ "$FAIL" -gt 0 ]]; then exit 1; fi
exit 0
