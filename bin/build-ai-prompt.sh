#!/usr/bin/env bash
# Build a single prompt file for the local Qwen model (send it with ask-ai.sh).
#   build-ai-prompt.sh anomaly      # anomaly-analysis prompt + every file in sanitized/
#   build-ai-prompt.sh remediation  # remediation-request prompt
set -euo pipefail

LAB=/opt/linux-ai-security-lab
mode="${1:-}"

case "$mode" in
  anomaly)
    out="$LAB/prompts/anomaly-bundle.txt"
    shopt -s nullglob
    files=("$LAB"/sanitized/*)
    if [[ ${#files[@]} -eq 0 ]]; then
      echo "No files in $LAB/sanitized/ - complete the sanitize steps first." >&2
      exit 1
    fi
    cat "$LAB/prompts/anomaly-analysis.txt" >"$out"
    for f in "${files[@]}"; do
      printf '\n\n===== %s =====\n' "$(basename "$f")" >>"$out"
      cat "$f" >>"$out"
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
