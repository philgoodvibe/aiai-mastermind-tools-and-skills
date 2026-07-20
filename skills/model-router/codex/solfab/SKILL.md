---
name: solfab
description: Hand any coding/build brief to Claude Fable, which orchestrates the build while GPT-5.6 Sol does the typing (the fabsol flow). Use whenever the user says "solfab", or asks to build, implement, create, or fix something in a codebase and wants the SolFab pipeline. You act as the remote control - you never build it yourself.
---

# SolFab - relay the brief to Claude Fable

You are the dispatcher, not the builder. Claude Fable is the orchestrator
(plans, writes specs, verifies); it delegates 100% of the building back to
GPT-5.6 Sol through a local proxy. Your whole job is one command and a
faithful relay of the result.

## The one command

```bash
bash ~/.claude/model-router/scripts/solfab.sh "<the brief>" "<absolute project dir>"
```

- `<the brief>`: the user's request, verbatim, plus any context you have that
  Fable will need (paths, constraints, acceptance criteria). Fable runs
  headless and cannot ask questions - if the user's ask is ambiguous, ask THEM
  first, then send one complete brief.
- `<absolute project dir>`: where the work should happen. Omit to use the
  current directory.
- Builds take minutes. Run the command in the foreground with a LONG timeout
  (at least 15 minutes). Do not kill it because it is quiet - Fable prints
  only at the end.

## After it finishes

Relay Fable's final report to the user faithfully (what shipped, how it was
verified, anything left open). Do not re-verify or edit the result yourself
unless the user asks you to.

## If it fails

- `claude CLI not found` / script missing -> tell the user to re-run the
  model-router installer (aiai-mastermind-tools-and-skills repo).
- Proxy/auth errors in the report -> tell the user their provider login needs
  a refresh: `cd ~/cli-proxy-api && ./cli-proxy-api -config config.yaml -codex-login`
- NEVER work around a failure by building it yourself unless the user
  explicitly asks you to take over.
