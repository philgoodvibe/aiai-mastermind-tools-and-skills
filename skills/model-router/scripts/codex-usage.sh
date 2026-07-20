#!/usr/bin/env bash
# Show ChatGPT/Codex subscription usage (weekly limit windows) for every Codex
# account the local proxy holds, via CLIProxyAPI's Management API.
# The access token never leaves the proxy - the $TOKEN$ placeholder is
# substituted server-side by CLIProxyAPI.
set -euo pipefail

URL="${MODEL_ROUTER_URL:-http://127.0.0.1:8317}"
MKEYFILE="$HOME/cli-proxy-api/.management-key"
if [ ! -f "$MKEYFILE" ]; then
  echo "No management key at $MKEYFILE."
  echo "Re-run the model-router install.sh to enable the usage view."
  exit 1
fi

bash "$HOME/.claude/model-router/scripts/start-proxy.sh" >/dev/null 2>&1 || true

MKEY="$(cat "$MKEYFILE")" URL="$URL" python3 - <<'EOF'
import json, os, urllib.request, datetime

URL, MKEY = os.environ["URL"], os.environ["MKEY"]

def call(path, payload=None):
    req = urllib.request.Request(URL + path,
        data=json.dumps(payload).encode() if payload else None,
        headers={"Authorization": "Bearer " + MKEY, "Content-Type": "application/json"},
        method="POST" if payload else "GET")
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)

def bar(pct, width=20):
    filled = round(pct / 100 * width)
    return "[" + "#" * filled + "-" * (width - filled) + "]"

def window_line(label, w):
    if not w:
        return None
    pct = w.get("used_percent", 0)
    days = w.get("limit_window_seconds", 0) / 86400
    reset = w.get("reset_after_seconds")
    reset_txt = ""
    if reset is not None:
        d, rem = divmod(int(reset), 86400)
        h, m = divmod(rem // 60, 60)
        reset_txt = f"  resets in {d}d {h}h" if d else f"  resets in {h}h {m}m"
        if w.get("reset_at"):
            at = datetime.datetime.fromtimestamp(w["reset_at"]).strftime("%a %b %-d, %-I:%M %p")
            reset_txt += f" ({at})"
    span = f"{days:.0f}-day" if days >= 1 else f"{w.get('limit_window_seconds',0)//3600}-hour"
    return f"  {label:<22} {bar(pct)} {pct:>3}% of {span} limit{reset_txt}"

files = call("/v0/management/auth-files").get("files", [])
codex = [f for f in files if f.get("provider") == "codex" and not f.get("disabled")]
if not codex:
    print("No Codex accounts in the proxy. Run: cd ~/cli-proxy-api && ./cli-proxy-api -config config.yaml -codex-login")
    raise SystemExit(0)

for f in codex:
    acc_id = (f.get("id_token") or {}).get("chatgpt_account_id", "")
    r = call("/v0/management/api-call", {
        "auth_index": f["auth_index"], "method": "GET",
        "url": "https://chatgpt.com/backend-api/wham/usage",
        "header": {"Authorization": "Bearer $TOKEN$", "Content-Type": "application/json",
                   "Chatgpt-Account-Id": acc_id,
                   "User-Agent": "codex_cli_rs/0.76.0 (Mac OS; arm64) Terminal"}})
    if r.get("status_code") != 200:
        print(f"{f.get('email','?')}: usage fetch failed (HTTP {r.get('status_code')}) - login may need a refresh")
        continue
    body = r.get("body")
    u = json.loads(body) if isinstance(body, str) else body

    plan = (u.get("plan_type") or "?").capitalize()
    print(f"ChatGPT Codex usage - {u.get('email', f.get('email','?'))} ({plan} plan)")
    rl = u.get("rate_limit") or {}
    line = window_line("Overall", rl.get("primary_window"))
    if line: print(line)
    line = window_line("Overall (secondary)", rl.get("secondary_window"))
    if line: print(line)
    for extra in u.get("additional_rate_limits") or []:
        w = (extra.get("rate_limit") or {}).get("primary_window")
        line = window_line(extra.get("limit_name", "extra"), w)
        if line: print(line)
    if rl.get("limit_reached"):
        print("  !! LIMIT REACHED - requests are being rejected until reset")
    credits = u.get("rate_limit_reset_credits") or {}
    if credits.get("available_count"):
        print(f"  Reset credits available: {credits['available_count']}")
    sub = (f.get("id_token") or {}).get("chatgpt_subscription_active_until")
    if sub:
        print(f"  Subscription active until: {sub[:10]}")
EOF
