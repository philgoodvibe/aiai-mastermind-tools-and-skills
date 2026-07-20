#!/usr/bin/env bash
# SolFab - the reverse entry point. Codex (ChatGPT app / Codex app / VSCode)
# hands a build brief to Claude Fable, which orchestrates the fabsol flow:
# Fable plans, specs, and verifies; GPT-5.6 Sol does the building via the proxy.
# So the chain is Sol -> Fable -> Sol ("solfabsol").
#
# Usage: solfab.sh "brief" [project-dir]
#
# The orchestrator runs on Claude Code's own direct Anthropic login - it is
# NEVER routed through the proxy. Only the headless Sol workers it spawns use
# the routed env vars.
set -euo pipefail

BRIEF="${1:?usage: solfab.sh \"brief\" [project-dir]}"
DIR="${2:-$PWD}"

# Resolve claude even from GUI-launched apps with a minimal PATH.
CLAUDE_BIN="$(command -v claude || true)"
for CAND in "$HOME/.local/bin/claude" "/opt/homebrew/bin/claude" "/usr/local/bin/claude"; do
  [ -n "$CLAUDE_BIN" ] && break
  [ -x "$CAND" ] && CLAUDE_BIN="$CAND"
done
[ -n "$CLAUDE_BIN" ] || { echo "solfab: claude CLI not found"; exit 1; }

# Routed-worker env for the fabsol delegations (NOT for the orchestrator itself).
KEYFILE="$HOME/cli-proxy-api/.model-router-key"
export MODEL_ROUTER_URL="${MODEL_ROUTER_URL:-http://127.0.0.1:8317}"
if [ -z "${MODEL_ROUTER_KEY:-}" ] && [ -f "$KEYFILE" ]; then
  MODEL_ROUTER_KEY="$(cat "$KEYFILE")"; export MODEL_ROUTER_KEY
fi
export MODEL_ROUTER_MODEL="${MODEL_ROUTER_MODEL:-gpt-5.6-sol}"
export MODEL_ROUTER_EFFORT="${MODEL_ROUTER_EFFORT:-low}"

bash "$HOME/.claude/model-router/scripts/start-proxy.sh" >/dev/null 2>&1 || true

cd "$DIR"
exec "$CLAUDE_BIN" -p "Invoke the fabsol skill and follow it end to end for this brief. You are running headless: the brief is final and pre-aligned, so skip the alignment questions and make every creative and architectural call yourself in the specs. Delegate ALL building to the routed worker exactly as the skill prescribes. Finish with the skill's 5-line report. Brief: $BRIEF" \
  --allowedTools "Bash,Read,Write,Edit,Glob,Grep,Skill,TodoWrite" \
  --permission-mode acceptEdits \
  --max-turns 40
