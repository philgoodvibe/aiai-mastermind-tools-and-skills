---
description: Show your ChatGPT/Codex weekly usage limits (via the local model-router proxy)
---

Run this command in the foreground and show its output to the user:

```bash
bash ~/.claude/model-router/scripts/codex-usage.sh
```

The output is already formatted - present it as-is inside a code block, then
add one short sentence of interpretation (e.g. how much weekly headroom is
left, or that the limit is reached and when it resets). If the script errors,
follow the instruction in the error message instead of improvising.
