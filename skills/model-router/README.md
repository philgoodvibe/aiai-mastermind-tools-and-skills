
# model-router

Run Claude Code on every subscription you already pay for.

Your main Claude session stays exactly as it is. This resource adds a local
"switchboard" (a proxy) that holds your OTHER subscription logins - ChatGPT,
Gemini, Grok, Kimi - and lets Claude Code send work to those models three
ways: as headless build workers, as whole terminal or VSCode sessions, or as
subagents. No API keys, no per-token bills - just the subscriptions you
already have. Every default (model, effort, turn cap) is changeable.

## FabSol - the flow that combines them

**FabSol lives in its own folder: [`skills/fabsol/`](skills/fabsol/SKILL.md).**
It is the flagship of this resource: the flow that orchestrates the two models
together. Your main model (Fable) plans, writes one self-contained spec per
task, and verifies - the routed worker model (Sol by default) does 100% of the
building. In our 7-test benchmark this shipped identical builds for 33% less
than the main model working alone, with most of the burn moved onto the second
subscription's spare capacity.

Invoke it as `/model-router:fabsol <brief>` (plugin install) or `/fabsol <brief>`
(manual install). Everything else in this resource exists to support that flow.

## Play it safe (read this first)

Anthropic's terms (updated Feb 2026) ban using a Claude **subscription** login
inside third-party tools - so this resource NEVER routes your Claude login
through the proxy. The design is one-directional: Claude Code runs on its
normal direct login and REACHES OUT to the other models. Keep it that way.

## What's inside

| Folder | What it is |
|---|---|
| `skills/fabsol/` | **the FabSol flow** - orchestrator + worker (the flagship) |
| `skills/model-router/` | the routing knowledge - three usage modes, model switching |
| `commands/fabsol.md` | thin command that invokes the fabsol skill with your brief |
| `agents/worker.md` | build-worker subagent for routed sessions |
| `scripts/` | start-proxy, worker, session, vscode - each as `.sh` (Mac/Linux) and `.ps1` (Windows) |
| `proxy/config.example.yaml` | ready-to-copy proxy config |

## Install - steps for the agent setting this up

Work through these in order. Ask the user for their preference where a step
offers a choice.

**Step 1 - install the proxy.** Download the latest
[CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI/releases) release
for the user's OS and unzip it somewhere stable (suggest `~/cli-proxy-api`).

**Step 2 - configure it.** Copy this resource's `proxy/config.example.yaml`
to `config.yaml` next to the proxy binary. Have the user pick their own value
for the `api-keys` entry (any string - it is the local password between
Claude Code and the proxy; `my-proxy-key` is the placeholder this README
assumes).

**Step 3 - log in to the other subscription(s).** Run from the proxy folder;
each opens a browser once and stores the login locally in `~/.cli-proxy-api`:

```bash
./cli-proxy-api -config config.yaml -codex-login        # ChatGPT / Codex (default worker)
# also available, same pattern:
#   -antigravity-login   Google Antigravity / Gemini
#   -xai-login           xAI Grok
#   -kimi-login          Kimi
```

**Step 4 - set the four env vars** in the user's shell profile (these are the
shipped defaults - see "Change the defaults" below):

```bash
# Mac/Linux (~/.zshrc or ~/.bashrc)
export MODEL_ROUTER_URL="http://127.0.0.1:8317"
export MODEL_ROUTER_KEY="my-proxy-key"        # the key from step 2
export MODEL_ROUTER_MODEL="gpt-5.6-sol"       # default worker model
export MODEL_ROUTER_EFFORT="low"              # default worker effort
```

```powershell
# Windows (persist once, from PowerShell)
[Environment]::SetEnvironmentVariable("MODEL_ROUTER_URL", "http://127.0.0.1:8317", "User")
[Environment]::SetEnvironmentVariable("MODEL_ROUTER_KEY", "my-proxy-key", "User")
[Environment]::SetEnvironmentVariable("MODEL_ROUTER_MODEL", "gpt-5.6-sol", "User")
[Environment]::SetEnvironmentVariable("MODEL_ROUTER_EFFORT", "low", "User")
```

**Step 5 - install the pieces into Claude Code.** Two options, either works:

- *Plugin route:* run `/plugin marketplace add <path-to-this-unzipped-folder>`
  then `/plugin install model-router@robonuggets`. Commands are namespaced:
  `/model-router:fabsol`.
- *Manual route:* copy `skills/fabsol/` and `skills/model-router/` into
  `~/.claude/skills/`, `commands/fabsol.md` into `~/.claude/commands/`
  (gives plain `/fabsol`), and `agents/worker.md` into `~/.claude/agents/`.

**Step 6 - verify.** Start the proxy (`scripts/start-proxy.sh` or `.ps1`),
then confirm the worker model is served:

```bash
curl -s "$MODEL_ROUTER_URL/v1/models" -H "Authorization: Bearer $MODEL_ROUTER_KEY"
```

Then run one cheap end-to-end test:

```bash
scripts/worker.sh "Reply with exactly: routing works"    # Windows: scripts\worker.ps1 "..."
```

If both answer, the setup is live. Try `/fabsol build me a small test page`.

## Change the defaults (everything is adjustable)

The resource SHIPS with: worker = `gpt-5.6-sol`, effort = `low`,
turn cap = `20`. Change any of them:

| What | How |
|---|---|
| Worker model, everywhere at once | set `MODEL_ROUTER_MODEL` to any ID your proxy serves |
| Worker model, one call | pass it as an argument (`scripts/worker.sh "task" gemini-3.5-flash`) or name it in your /fabsol brief |
| Worker effort | set `MODEL_ROUTER_EFFORT` (`low` ships; raise to `medium` if builds miss acceptance criteria - higher mostly burns tokens: in our tests xhigh made the worker grind 2-3x more turns for the same output) |
| Turn cap | edit `--max-turns 20` in `skills/fabsol/SKILL.md` (raise for bigger multi-file tasks) |
| Proxy address / key | `MODEL_ROUTER_URL` / `MODEL_ROUTER_KEY` |

**Which models can you point at?** Any ID your proxy serves. Discover them:

```bash
curl -s "$MODEL_ROUTER_URL/v1/models" -H "Authorization: Bearer $MODEL_ROUTER_KEY"
```

| Provider | Login flag | Example models |
|---|---|---|
| OpenAI / Codex | `-codex-login` | `gpt-5.6-sol` (default), GPT-5.5 family |
| Google Antigravity / Gemini | `-antigravity-login` | Gemini 3.5 Flash, Gemini 3.1 Pro, newer tiers where served |
| xAI Grok | `-xai-login` | Grok 4.5, Grok Composer 2.5 Fast |
| Kimi | `-kimi-login` | Kimi K2.7 Code, K2.6 |
| Google Vertex | `-vertex-import key.json` | your Vertex-served models |

Only providers you've logged into appear. Model IDs vary by CLIProxyAPI
version - always trust your own `/v1/models` list over this table.

## Launch Claude Code ON the routed model

Besides FabSol (where your normal session delegates), you can run a whole
Claude Code session on the routed model:

**Terminal:**

```bash
scripts/session.sh              # default worker model
scripts/session.sh grok-4.5     # any model your proxy serves
```

Windows: `scripts\session.ps1 [model]`. Or by hand - set the two env vars and
launch (scoped to that terminal, closes with it):

```powershell
$env:ANTHROPIC_BASE_URL = "http://127.0.0.1:8317"
$env:ANTHROPIC_AUTH_TOKEN = "my-proxy-key"
claude --model gpt-5.6-sol
```

**VSCode:**

```bash
scripts/vscode.sh [folder]      # Windows: scripts\vscode.ps1 [folder]
```

Opens a VSCode window whose Claude Code sessions run on the routed model. It
uses a separate VSCode profile folder on purpose: an already-running VSCode
ignores env vars from new launches, so this is the way that always works.
Alternative if you prefer your normal profile: fully close VSCode, set the two
env vars in a terminal, then run `code .` from that terminal.

In a routed session (terminal or VSCode), the plugin's `worker` subagent
resolves too - so even subagents run on routed models there.

## Troubleshooting

- **"Connection refused" on delegation** - the proxy isn't running. Run the
  start-proxy script.
- **Auth error from the proxy** - your provider login expired. Re-run the login
  flag for that provider (step 3).
- **"Unknown provider for model X"** - that provider isn't logged in, or the ID
  is wrong. Check the `/v1/models` list.
- **VSCode window doesn't route** - VSCode was already running with its normal
  env. Use `scripts/vscode` (separate profile), or close VSCode fully first.
- **Worker output is weak** - the spec is doing too little work. The
  orchestrator must make every creative/architectural call in the spec; the
  worker just types. Raising `MODEL_ROUTER_EFFORT` to `medium` is the second lever.

## License

CC BY 4.0 - free to use, adapt, and share with attribution to RoboNuggets.
