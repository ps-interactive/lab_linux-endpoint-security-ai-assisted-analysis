#!/usr/bin/env bash
# Build a single prompt file for GPT4All and copy it to the clipboard when possible.
#   build-ai-prompt.sh anomaly      # anomaly-analysis prompt + every file in sanitized/
#   build-ai-prompt.sh remediation  # remediation-request prompt
set -euo pipefail

LAB=/opt/linux-ai-security-lab
mode="${1:-}"

case "$mode" in
  anomaly)
    out="$LAB/prompts/anomaly-bundle.txt"
    cat "$LAB/prompts/anomaly-analysis.txt" >"$out"
    shopt -s nullglob
    files=("$LAB"/sanitized/*)
    if [[ ${#files[@]} -eq 0 ]]; then
      echo "No files in $LAB/sanitized/ - complete the sanitize steps first." >&2
      exit 1
    fi
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

export DISPLAY="${DISPLAY:-:10}"
if command -v xclip >/dev/null 2>&1 && xclip -selection clipboard <"$out" 2>/dev/null; then
  echo "Copied to clipboard. Paste into GPT4All with Ctrl+V."
elif command -v xsel >/dev/null 2>&1 && xsel --clipboard --input <"$out" 2>/dev/null; then
  echo "Copied to clipboard. Paste into GPT4All with Ctrl+V."
else
  echo "Clipboard unavailable. Open $out in a text editor, select all, and copy."
fi
