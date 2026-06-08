---
description: Generate image(s) via Codex CLI ChatGPT OAuth (built-in image_gen, no API key)
argument-hint: [what to generate — e.g. "hero photo of a mountain, 16:9, save to ./public/hero.png"]
---

Generate one or more images using Codex CLI's built-in `image_gen` tool through the ChatGPT OAuth session — **not** the OpenAI API.

**REQUIRED:** Use the `gpt-image` skill and follow its workflow exactly (built-in tool, `mv` not `cp`, absolute paths, verify).

Request: $ARGUMENTS

If the request is missing details, ask for the subject/scene, the aspect ratio(s), and the absolute destination path(s) before generating. After generating: MOVE (not copy) each output to its destination, `rmdir` the emptied Codex cache session folder, then show the results.
