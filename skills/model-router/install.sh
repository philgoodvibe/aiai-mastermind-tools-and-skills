#!/usr/bin/env bash
# model-router installer (macOS / Linux) - AiAi Mastermind packaging of the
# RoboNuggets model-router plugin (CC BY 4.0) + CLIProxyAPI.
#
# What it does (idempotent - safe to re-run):
#   1. Downloads the latest CLIProxyAPI release for this OS/arch to ~/cli-proxy-api
#      and verifies its sha256 checksum.
#   2. Writes ~/cli-proxy-api/config.yaml with a freshly generated local key
#      (kept in ~/cli-proxy-api/.model-router-key; existing key is reused).
#   3. Installs the fabsol + model-router skills, /fabsol command, and worker
#      agent globally into ~/.claude, plus a full plugin copy at ~/.claude/model-router.
#   4. Appends MODEL_ROUTER_* env vars to your shell profile (~/.zshrc or ~/.bashrc).
#
# What it does NOT do: the one interactive step - signing in to your ChatGPT
# (or other) subscription. The script prints that command at the end.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXY_DIR="$HOME/cli-proxy-api"
CLAUDE_DIR="$HOME/.claude"

# --- 1. detect platform -------------------------------------------------------
OS="$(uname -s)"; ARCH="$(uname -m)"
case "$OS" in
  Darwin) PLAT="darwin" ;;
  Linux)  PLAT="linux" ;;
  *) echo "Unsupported OS: $OS (Windows: follow INSTALL.md manually with the .ps1 scripts)"; exit 1 ;;
esac
case "$ARCH" in
  arm64|aarch64) A="aarch64" ;;
  x86_64|amd64)  A="amd64" ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

# --- 2. download + verify CLIProxyAPI -----------------------------------------
echo ">> Fetching latest CLIProxyAPI release info..."
API_JSON="$(curl -fsSL https://api.github.com/repos/router-for-me/CLIProxyAPI/releases/latest)"
TAG="$(printf '%s' "$API_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')"
ASSET="CLIProxyAPI_${TAG#v}_${PLAT}_${A}.tar.gz"
BASE="https://github.com/router-for-me/CLIProxyAPI/releases/download/$TAG"

INSTALLED_VER=""
[ -x "$PROXY_DIR/cli-proxy-api" ] && INSTALLED_VER="$("$PROXY_DIR/cli-proxy-api" --help 2>&1 | grep -m1 -o 'Version: [0-9.]*' || true)"
if [ "$INSTALLED_VER" = "Version: ${TAG#v}" ]; then
  echo ">> CLIProxyAPI $TAG already installed at $PROXY_DIR - skipping download."
else
  TMP="$(mktemp -d)"
  echo ">> Downloading $ASSET ..."
  curl -fsSL -o "$TMP/pkg.tar.gz" "$BASE/$ASSET"
  curl -fsSL -o "$TMP/checksums.txt" "$BASE/checksums.txt"
  WANT="$(grep " $ASSET\$" "$TMP/checksums.txt" | awk '{print $1}')"
  GOT="$(shasum -a 256 "$TMP/pkg.tar.gz" 2>/dev/null | awk '{print $1}' || sha256sum "$TMP/pkg.tar.gz" | awk '{print $1}')"
  if [ -z "$WANT" ] || [ "$WANT" != "$GOT" ]; then
    echo "!! Checksum mismatch for $ASSET - aborting."; rm -rf "$TMP"; exit 1
  fi
  echo ">> Checksum OK. Installing to $PROXY_DIR ..."
  mkdir -p "$PROXY_DIR"
  tar -xzf "$TMP/pkg.tar.gz" -C "$PROXY_DIR"
  rm -rf "$TMP"
fi

# --- 3. config.yaml with a local key ------------------------------------------
KEY_FILE="$PROXY_DIR/.model-router-key"
if [ -f "$KEY_FILE" ]; then
  KEY="$(cat "$KEY_FILE")"
  echo ">> Reusing existing local key from $KEY_FILE"
else
  KEY="mr-$(openssl rand -hex 12 2>/dev/null || head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  printf '%s\n' "$KEY" > "$KEY_FILE"; chmod 600 "$KEY_FILE"
  echo ">> Generated local proxy key (stored in $KEY_FILE)"
fi
MGMT_KEY_FILE="$PROXY_DIR/.management-key"
if [ -f "$MGMT_KEY_FILE" ]; then
  MGMT_KEY="$(cat "$MGMT_KEY_FILE")"
else
  MGMT_KEY="mgmt-$(openssl rand -hex 12 2>/dev/null || head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  printf '%s\n' "$MGMT_KEY" > "$MGMT_KEY_FILE"; chmod 600 "$MGMT_KEY_FILE"
fi
if [ ! -f "$PROXY_DIR/config.yaml" ]; then
  sed -e "s/my-proxy-key/$KEY/" -e "s/my-management-key/$MGMT_KEY/" \
    "$HERE/proxy/config.example.yaml" > "$PROXY_DIR/config.yaml"
  echo ">> Wrote $PROXY_DIR/config.yaml"
elif ! grep -q "remote-management" "$PROXY_DIR/config.yaml"; then
  cat >> "$PROXY_DIR/config.yaml" <<EOF

# Management API - localhost only; used by the /codex-usage command.
remote-management:
  allow-remote: false
  secret-key: "$MGMT_KEY"
EOF
  echo ">> Enabled Management API in existing config.yaml (for /codex-usage)."
else
  echo ">> $PROXY_DIR/config.yaml already exists - leaving it untouched."
fi

# --- 4. install skills globally into ~/.claude ---------------------------------
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/agents"
rm -rf "$CLAUDE_DIR/skills/fabsol" "$CLAUDE_DIR/skills/model-router" "$CLAUDE_DIR/model-router"
cp -R "$HERE/skills/fabsol"       "$CLAUDE_DIR/skills/fabsol"
cp -R "$HERE/skills/model-router" "$CLAUDE_DIR/skills/model-router"
cp "$HERE/commands/"*.md          "$CLAUDE_DIR/commands/"
cp "$HERE/agents/worker.md"       "$CLAUDE_DIR/agents/worker.md"
cp -R "$HERE" "$CLAUDE_DIR/model-router"
chmod +x "$CLAUDE_DIR/model-router/scripts/"*.sh
echo ">> Installed skills (fabsol, model-router), /fabsol command, worker agent into $CLAUDE_DIR"

# --- 4b. SolFab: Codex-side dispatcher (only if Codex CLI is set up) -----------
if [ -d "$HOME/.codex" ]; then
  mkdir -p "$HOME/.codex/skills/solfab"
  cp "$HERE/codex/solfab/SKILL.md" "$HOME/.codex/skills/solfab/SKILL.md"
  if ! grep -q "SolFab - hand build briefs" "$HOME/.codex/AGENTS.md" 2>/dev/null; then
    tail -n +3 "$HERE/codex/AGENTS-snippet.md" >> "$HOME/.codex/AGENTS.md"
  fi
  echo ">> Installed SolFab dispatcher into ~/.codex (skill + AGENTS.md section)"
else
  echo ">> Codex CLI not detected (~/.codex missing) - skipped SolFab dispatcher."
  echo "   Install Codex, sign in, re-run this script to enable ChatGPT-app dispatch."
fi

# --- 5. env vars in shell profile ----------------------------------------------
case "${SHELL:-}" in
  */zsh) PROFILE="$HOME/.zshrc" ;;
  *)     PROFILE="$HOME/.bashrc" ;;
esac
if ! grep -q "MODEL_ROUTER_URL" "$PROFILE" 2>/dev/null; then
  cat >> "$PROFILE" <<EOF

# model-router (robonuggets via aiai-mastermind-tools-and-skills) - local CLIProxyAPI switchboard
export MODEL_ROUTER_URL="http://127.0.0.1:8317"
export MODEL_ROUTER_KEY="$KEY"
export MODEL_ROUTER_MODEL="gpt-5.6-sol"
export MODEL_ROUTER_EFFORT="low"
export CLIPROXY_DIR="\$HOME/cli-proxy-api"
EOF
  echo ">> Added MODEL_ROUTER_* env vars to $PROFILE"
else
  echo ">> MODEL_ROUTER_* env vars already in $PROFILE - leaving them untouched."
fi

# --- 6. next steps --------------------------------------------------------------
cat <<EOF

============================================================
Install complete. TWO steps remain (the first needs a human):

1. Sign in to the subscription you want to route to (opens a
   browser once; login is stored locally in ~/.cli-proxy-api):

     cd ~/cli-proxy-api && ./cli-proxy-api -config config.yaml -codex-login

   (Other providers: -antigravity-login, -xai-login, -kimi-login)

2. Start the proxy and verify:

     source $PROFILE
     bash ~/.claude/model-router/scripts/start-proxy.sh
     curl -s "\$MODEL_ROUTER_URL/v1/models" -H "Authorization: Bearer \$MODEL_ROUTER_KEY"
     bash ~/.claude/model-router/scripts/worker.sh "Reply with exactly: routing works"

Then open a NEW terminal (or restart VSCode fully) and try:
     /fabsol build me a small test page      (orchestrated build)
     /sol <any quick task>                   (one-shot on the routed model)
     /codex-usage                            (weekly ChatGPT/Codex limits)

SolFab (dispatch from Codex / the ChatGPT app), if Codex is
installed - test it from any Codex session with:
     solfab: create hello.txt containing exactly 'chain works'
============================================================
EOF
