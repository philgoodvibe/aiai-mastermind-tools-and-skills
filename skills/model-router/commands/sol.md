---
description: Run a one-shot task on the routed Codex model (gpt-5.6-sol by default) and relay its answer
---

The task: $ARGUMENTS

Run the task on the routed worker model via the local proxy, in the
foreground, and relay the result:

```bash
bash ~/.claude/model-router/scripts/worker.sh "<the task, made self-contained>"
```

- If the task names a different model (e.g. "on terra", "with gemini"), pass
  it as the second argument: `worker.sh "task" gpt-5.6-terra`.
- The worker runs headless in the current directory with edit permissions -
  for pure questions it just answers; for file tasks it builds and reports.
- Relay the worker's output faithfully. Do not redo or embellish its work.
- Connection refused -> start the proxy first:
  `bash ~/.claude/model-router/scripts/start-proxy.sh`, then retry once.
