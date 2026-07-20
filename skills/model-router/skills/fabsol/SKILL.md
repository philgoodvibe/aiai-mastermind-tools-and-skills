---
name: fabsol
description: The FabSol flow - the flagship of this plugin. Your main model (e.g. Claude Fable) orchestrates - plans, writes specs, verifies - while the routed worker model (GPT-5.6 Sol by default) does 100% of the building through the local proxy. Use for any real build task.
---

# FabSol - the orchestrator + worker build flow

This is the flow that combines the two models. The name is Fable + Sol, but it
works with any pair: your main session model orchestrates, and whatever model
`MODEL_ROUTER_MODEL` points at does the building.

You are the ORCHESTRATOR, running on this session's normal login - NEVER route
this session through the proxy. All building is delegated to the WORKER model
via headless `claude -p` calls through the local proxy (CLIProxyAPI), which
holds the user's other subscription logins.

## Configuration (all changeable - see the README's "Change the defaults")

| Setting | Env var | Ships as |
|---|---|---|
| Proxy URL | `MODEL_ROUTER_URL` | `http://127.0.0.1:8317` |
| Proxy key | `MODEL_ROUTER_KEY` | `my-proxy-key` (an `api-keys` entry in your proxy config.yaml) |
| Worker model | `MODEL_ROUTER_MODEL` | `gpt-5.6-sol` |
| Worker effort | `MODEL_ROUTER_EFFORT` | `low` |
| Worker turn cap | `--max-turns` in the call below | `20` |

The worker ships cheap-and-fast (low effort, bare harness, 20-turn cap) and
holds up because the spec you write carries the thinking. If builds keep
missing acceptance criteria, raise the effort to `medium`. Bigger multi-file
tasks getting cut off: raise the turn cap.

## The worker delegation call (Bash, one per build task)

```bash
ANTHROPIC_BASE_URL="${MODEL_ROUTER_URL:-http://127.0.0.1:8317}" \
ANTHROPIC_AUTH_TOKEN="${MODEL_ROUTER_KEY:-my-proxy-key}" \
claude -p "<self-contained task spec>" \
  --model "${MODEL_ROUTER_MODEL:-gpt-5.6-sol}" \
  --effort "${MODEL_ROUTER_EFFORT:-low}" \
  --bare --max-turns 20 --permission-mode acceptEdits \
&& ls -la <expected output paths> \
&& grep -c "<acceptance marker>" <built file>
```

`--bare` is safe for the worker because its auth comes from the env vars on the
call, not a stored login. The `&& ls && grep` tail is not decoration - it is
how the build's proof comes back in the same tool result (rule 2 below).

## ORCHESTRATOR EFFICIENCY RULES (non-negotiable)

Every tool call you make is a full API round trip that re-sends your entire
context. Turns are the cost driver, so:

1. **You never write code.** The worker does 100% of the building. When a
   build misses, you delegate a fix task WITH the failure evidence attached -
   you do not open an editor yourself. The only things you write are specs,
   verdicts, and the final report.
2. **One compound command per delegation.** Chain the verification evidence
   onto the SAME Bash call as the delegation (the `&& ls && grep` tail above,
   plus targeted `head -40` slices if needed) so the build result AND its
   proof arrive in one tool result.
3. **Never read a whole built file into context.** It rides along in every
   later turn and you pay for it again each time. Verify with targeted
   `grep -c` / `head` / `tail` slices only.
4. **No exploratory reads before the spec.** If the brief touches existing
   code, gather everything in ONE batched Bash call (`ls` + `grep` + `head`
   slices), then write the spec.
5. **Target shape: 2 turns per task.** Turn 1 = spec + compound
   delegate-and-verify call. Turn 2 = report. Spend a third turn only on an
   actual failure.
6. **Run delegations in the FOREGROUND** - wait for each to finish. Never end
   the session with worker builds still in flight (fire-and-forget loses the
   build report). Independent tasks may run as parallel background calls, but
   collect all of them before reporting.

## Before the first delegation

Check the proxy is up:

```bash
curl -s "${MODEL_ROUTER_URL:-http://127.0.0.1:8317}/v1/models" \
  -H "Authorization: Bearer ${MODEL_ROUTER_KEY:-my-proxy-key}"
```

It must list your worker model. If it does not respond, start it with the
plugin's `scripts/start-proxy` script (`.ps1` on Windows, `.sh` on Mac/Linux)
and re-check. If a delegation fails with an auth error, STOP and tell the user
their provider login needs a refresh (see the README's login table).

## Phase 1 - ALIGN AND PLAN (you)

- Ask at least 3 alignment questions in ONE batch before any work: scope,
  constraints, what done looks like. Wait for answers. (Skip only if the brief
  explicitly says it is final and pre-aligned.)
- Write a short plan: numbered build tasks, each sized so a single headless
  call can finish it without asking questions.
- Show the plan in one screen or less. Get a go signal.

## Phase 2 - BUILD (the worker, headless)

- One delegation call per task, using the exact compound command shape above.
- Each task spec must be self-contained: exact file paths, what to create or
  change, acceptance criteria, what NOT to touch, and "verify your work, then
  report changed paths + how you verified".
- Since the worker runs at low effort, the spec carries the intelligence:
  make every creative and architectural call yourself, in the spec.

## Phase 3 - CHECK (you) - optional for quick tasks, recommended for real builds

- Judge from the compound command's evidence: file list, grep counts, targeted
  slices. Run the real verification (build command, test run) batched into as
  few Bash calls as possible. The compound command already returned the basic
  proof, so this phase costs almost nothing - skip it only when the stakes are low.
- Misses go back to the worker as a fix delegation with the failure evidence
  attached. You do not fix code yourself.
- Report: what shipped, what was verified and how, anything left open -
  5 lines or fewer.
