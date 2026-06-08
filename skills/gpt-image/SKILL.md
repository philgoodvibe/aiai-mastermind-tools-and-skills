---
name: gpt-image
description: Use when asked to generate, create, make, render, draw, or mock up an image, photo, picture, hero image, illustration, icon, texture, sprite, or visual asset from Claude Code, and no usable OPENAI_API_KEY is set but Codex CLI is installed and signed in to ChatGPT (OAuth). Also triggered by /gpt-image. Routes image generation through Codex's built-in tool, never the OpenAI API.
---

# gpt-image

## Overview

Generate images from Claude Code using a **ChatGPT subscription** (no paid API key) by delegating to **Codex CLI's built-in `image_gen` tool**, which runs through the user's ChatGPT OAuth session.

**Core rule: a ChatGPT OAuth login is NOT an API key.** Do not call the OpenAI Images API — the OAuth token lacks image scope and returns `401 missing scopes: api.model.images.request`. Codex's built-in `image_gen` tool needs no key. Always route through Codex.

## When to use

- Any request to generate / create / make / render / draw an image, photo, mockup, hero, banner, illustration, icon, sprite, or texture from Claude Code.
- The machine has Codex CLI plus a ChatGPT login, and there is no usable `OPENAI_API_KEY`.

**Do NOT use when:** a real `OPENAI_API_KEY` is available and direct API control is wanted, or the asset is better authored as code/SVG.

## Prerequisites

- `codex --version` succeeds (Codex CLI installed).
- Codex is signed in to ChatGPT (authenticated via OAuth).
- Do **not** read the key out of `~/.codex/auth.json` — Claude Code's credential safety layer blocks it, and there is no usable image key there anyway. If image generation fails, report the error; do not hunt for a key.

## Workflow

1. **Write a brief** (plain text): shared style + per-image subject/composition + aspect ratio + **ABSOLUTE** destination path + constraints ("only write these files, no git, don't edit the repo").
2. **Run Codex headless:**
   ```bash
   codex exec --sandbox workspace-write \
     -c sandbox_workspace_write.network_access=true \
     --skip-git-repo-check "$(< /abs/path/to/brief.txt)"
   ```
   Run it in the background for batches; then read the output file.
3. **Force the built-in tool in the brief:** tell Codex to use its **built-in `image_gen` tool** (one call per image). Explicitly forbid the OpenAI Images API and one-off SDK scripts — that path 401s on OAuth.
4. **Single location — MOVE, don't copy.** The built-in tool always writes to `~/.codex/generated_images/<session>/` first. Instruct Codex to **`mv`** (never `cp`) each file to the absolute destination, then `rmdir` the emptied session folder. Never touch other session folders (the user's prior work).
5. **Verify:** open the saved images, confirm subject/quality/brand, confirm the destination holds the files and the cache session is gone.

## Brief template (copy, fill the brackets)

```
GENERATE <N> images using your BUILT-IN image_gen tool (one call each).
Do NOT call the OpenAI Images API and do NOT write an SDK script.
After each image, MOVE it (mv, not cp) to the ABSOLUTE path given, then
rmdir the now-empty ~/.codex/generated_images/<session> folder.
Do not run git or modify any other file.

SHARED STYLE: <style / palette / mood — optional>
AVOID: <negatives, e.g. text, logos, extra fingers>

1) <landscape|square|portrait> -> <subject + composition> -> /abs/path/name1.png
2) ...
When done, print each saved ABSOLUTE path.
```

## Aspect ratios

Built-in output comes in buckets: landscape ~1672×941, square ~1254×1254, portrait 1024×1536. Exact pixel dimensions need a post-crop/resize step (e.g. `sips`).

## Common mistakes

| Mistake | Fix |
|---|---|
| Calling the OpenAI Images API with the OAuth token | 401 missing scope. Use the built-in `image_gen` tool. |
| `cp` instead of `mv` | Leaves a 1:1 duplicate in `~/.codex/generated_images` (wasted disk). Always `mv`, then `rmdir` the empty session dir. |
| Relative output path | Resolves to Codex's cwd (often repo root), not your folder. Use ABSOLUTE paths. |
| `n>1` for different scenes | `n` = variants of ONE prompt. Distinct images need distinct `image_gen` calls. |
| Sandbox blocks the network call | Add `-c sandbox_workspace_write.network_access=true`. |
| Trusting "done" | The tool reports success even when composition drifts. Open the files and check. |
| Reading `~/.codex/auth.json` for a key | Blocked and pointless. Let Codex use its own session. |

## Portability

This skill is machine-local. To use it on another computer, that machine needs: Claude Code, Codex CLI installed, and Codex signed in to ChatGPT. Copy this `gpt-image/` folder into that machine's `~/.claude/skills/`.
