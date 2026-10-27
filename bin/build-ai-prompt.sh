#!/usr/bin/env bash
# Build a single prompt file for the local Qwen model (send it with ask-ai.sh).
#   build-ai-prompt.sh anomaly      # anomaly-analysis prompt + sanitized auth, syslog, journal
#   build-ai-prompt.sh remediation  # remediation-request prompt
set -euo pipefail

LAB=/opt/linux-ai-security-lab
mode="${1:-}"

case "$mode" in
  anomaly)
    out="$LAB/prompts/anomaly-bundle.txt"
    # Only these three files are sent. The full process list is too large for the
    # model's context window and is not needed for the analysis.
    files=(auth-sample.sanitized.log syslog-sample.sanitized.log lab-http.journal.sanitized.txt)
    for name in "${files[@]}"; do
      if [[ ! -f "$LAB/sanitized/$name" ]]; then
        echo "Missing $LAB/sanitized/$name - complete the sanitize steps first." >&2
        exit 1
      fi
    done
    cat "$LAB/prompts/anomaly-analysis.txt" >"$out"
    for name in "${files[@]}"; do
      printf '\n\n===== %s =====\n' "$name" >>"$out"
      cat "$LAB/sanitized/$name" >>"$out"
    done
    ;;
  remediation)
    out="$LAB/prompts/remediation-bundle.txt"
    cat "$LAB/prompts/remediation-request.txt" >"$out"
    ;;
  *)
    echo "Usage: $(basename "$0") anomaly|remediation" >&2
    exit 1
    ;;
esac

echo "Wrote $out"
