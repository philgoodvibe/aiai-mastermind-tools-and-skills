# AiAi Mastermind — Tools & Skills

A public collection of shareable [Agent Skills](https://agentskills.io) for Claude Code (and other agents like Codex, Gemini, Aider, Cursor). Drop them into your agent and go.

## Skills

### 🧠 [`wiki-llm`](skills/wiki-llm) — build a compounding knowledge wiki from your documents

Turn a folder of source documents (books, PDFs, papers, articles, transcripts) into a **persistent, interlinked Obsidian knowledge base maintained by an LLM** — the opposite of RAG. The LLM reads each source once and *compiles* it into cross-referenced markdown pages that sit between you and the raw sources, so the synthesis and contradictions are already there and the wiki gets richer with every source you add.

Implements [Andrej Karpathy's `llm-wiki` idea](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). Domain-agnostic — works for research, a company knowledge base, a single book, a hobby deep-dive, or a business.

It ships with:
- the three-layer **RAW → WIKI → OUTPUT** architecture and the hard extraction-vs-editorial boundary,
- a domain-agnostic schema template (`CLAUDE.md.template`) + five page templates (source / author / concept / framework / synthesis),
- ready-to-drop `.obsidian/` config — graph color groups, properties, and a CSS snippet that color-codes page types in note view,
- the **parallel-ingestion fan-out pattern** for ingesting dozens of sources at once,
- the **raw-traceback protocol** (page-cited quotes that trace back to the original file).

### 🖼️ [`gpt-image`](skills/gpt-image) — generate images from Claude Code using your ChatGPT subscription (no API key)

Let Claude Code create images (hero shots, product mockups, illustrations, icons, textures) by delegating to **Codex CLI's built-in `image_gen` tool** over your **ChatGPT OAuth login** — no `OPENAI_API_KEY`, no per-image API billing. The core insight: a ChatGPT OAuth token is *not* an API key (the Images API returns `401 missing scope` on it), so the skill routes every request through Codex's built-in tool instead of the API.

It enforces the things that are easy to get wrong:
- **OAuth, not API** — built-in `image_gen` via the signed-in ChatGPT session, never a raw API call.
- **One copy on disk** — `mv` (never `cp`) each output out of Codex's cache, so generated images never silently duplicate.
- absolute output paths, one call per image, a network-enabled sandbox, and a fill-in-the-blanks brief template for any use case.

Auto-triggers on "generate / create / make an image"; also ships an optional `/gpt-image` slash command. Requires the Codex CLI installed and signed in to ChatGPT.

## Install

**Claude Code** (personal skills):

```bash
git clone https://github.com/philgoodvibe/aiai-mastermind-tools-and-skills.git

# wiki-llm
cp -R aiai-mastermind-tools-and-skills/skills/wiki-llm ~/.claude/skills/wiki-llm

# gpt-image (+ optional /gpt-image slash command)
cp -R aiai-mastermind-tools-and-skills/skills/gpt-image ~/.claude/skills/gpt-image
cp aiai-mastermind-tools-and-skills/skills/gpt-image/gpt-image.command.md ~/.claude/commands/gpt-image.md
```

Then just ask: *"build a wiki LLM from these PDFs"* or *"generate a hero image of …"* and the matching skill activates. (`gpt-image` needs the Codex CLI installed and signed in to ChatGPT via `codex login`.)

**Other agents:** copy the skill folder into your agent's skills directory (e.g. `~/.agents/skills/` for Codex), or point your agent at `skills/wiki-llm/SKILL.md`.

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, share it.

## Starter kits

### `maya-starter/` - Your Automated Social Media Content Team

The complete starter kit for the AIAI Mastermind course "Your Automated Social Media Content Team". It sets up MAYA, the AI agent that runs your content team, with Codex as the copywriter and designer she manages.

Includes: MAYA's standing instructions (CLAUDE.md), a fill-in-the-blanks job description brief, a compliance knowledge-base template, three content-lane skills (newsjacking, problem-solution, entertain), a compliance-check skill, a Mai Marketing Machine posting skill, an image and brand skill, and the brain folder where your My Agency Context document lives.

Setup (covered step by step in the course):

```bash
git clone https://github.com/philgoodvibe/aiai-mastermind-tools-and-skills.git
cp -R aiai-mastermind-tools-and-skills/maya-starter ~/Documents/your-agency-content-team
```

Then open the folder in VS Code, drop your `My_Agency_Context.md` into `brain/`, and follow `JOB-DESCRIPTION.md`.
