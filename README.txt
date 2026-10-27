Linux Endpoint Security: AI-Assisted Analysis Lab
=================================================

Workflow: Collect -> Minimize -> Sanitize -> Analyze -> Remediate -> Verify

Directories:
  telemetry/     Synthetic and live-collected endpoint data
  sanitized/     Place sanitized copies here, starts empty
  prompts/       Starter prompts for the local LLM
  remediation/   Store AI-generated scripts you review before running
  examples/      Known-good reference scripts (use as reference if AI draft is wrong)

Local LLM — GPT4All with the Qwen model is preinstalled (nothing to download).
Build a prompt bundle:
  build-ai-prompt.sh anomaly
  build-ai-prompt.sh remediation
Send it to the model (a response can take up to about five minutes):
  ask-ai.sh anomaly
  ask-ai.sh remediation

Useful investigation commands:
  ps aux
  ss -tulnp
  journalctl -u lab-http.service
  journalctl -n 100
  systemctl status lab-http.service

Sanitize before analysis. Do not paste raw hostnames, usernames, IPs, or PIDs
into external AI systems. This lab uses a local model only.
