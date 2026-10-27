#!/usr/bin/env bash
# Send a lab prompt to the local GPT4All + Qwen model and save the response.
#   ask-ai.sh anomaly      builds the anomaly bundle, saves remediation/ai-anomaly-analysis.txt
#   ask-ai.sh remediation  builds the remediation bundle, saves remediation/ai-remediation-raw.txt
# The model runs on the CPU, so a response can take up to about ten minutes.
set -euo pipefail

LAB=/opt/linux-ai-security-lab
VENV_PY=/home/ubuntu/gpt4all/venv/bin/python3
MODEL_DIR=/home/ubuntu/LLM_models
MODEL_FILE=qwen2.5-7b-instruct-q3_k_m.gguf
mode="${1:-}"

case "$mode" in
  anomaly)     bundle="$LAB/prompts/anomaly-bundle.txt";     out="$LAB/remediation/ai-anomaly-analysis.txt" ;;
  remediation) bundle="$LAB/prompts/remediation-bundle.txt"; out="$LAB/remediation/ai-remediation-raw.txt" ;;
  *) echo "Usage: $(basename "$0") anomaly|remediation" >&2; exit 2 ;;
esac

build-ai-prompt.sh "$mode" >/dev/null
echo "Prompt: $bundle ($(wc -l < "$bundle") lines)"
echo "Asking the local Qwen model. This can take a few minutes..."
echo "----------------------------------------------------------------"

# The model files live under the ubuntu user's home, so run the model as ubuntu
# and let the calling user own the saved output. The model sometimes keeps
# writing a made-up next turn after its answer, so output is cut at the first
# stop marker (a short hold-back keeps stray "#" characters from being printed).
sudo -u ubuntu "$VENV_PY" -c '
import sys
from gpt4all import GPT4All

model_dir, model_file, bundle = sys.argv[1:4]
markers = ("<|endoftext|>", "<|im_end|>", "### User")
holdback = 24
prompt = open(bundle).read()
model = GPT4All(model_file, model_path=model_dir, allow_download=False, device="cpu", n_ctx=8192)

text = ""
printed = 0
stopped = False
with model.chat_session():
    for token in model.generate(prompt, max_tokens=700, temp=0.2, streaming=True):
        text += token
        cuts = [text.find(m) for m in markers if m in text]
        if cuts:
            end = min(cuts)
            print(text[printed:end].rstrip("# \n"), flush=True)
            stopped = True
            break
        safe = len(text) - holdback
        if safe > printed:
            print(text[printed:safe], end="", flush=True)
            printed = safe
if not stopped:
    print(text[printed:], flush=True)
' "$MODEL_DIR" "$MODEL_FILE" "$bundle" 2>/dev/null | tee "$out" \
  || { echo "ask-ai.sh: the model call failed. Run the command again." >&2; exit 1; }

echo "----------------------------------------------------------------"
echo "Saved to $out"
