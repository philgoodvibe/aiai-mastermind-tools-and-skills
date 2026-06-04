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

## Install

**Claude Code** (personal skills):

```bash
git clone https://github.com/philgoodvibe/aiai-mastermind-tools-and-skills.git
cp -R aiai-mastermind-tools-and-skills/skills/wiki-llm ~/.claude/skills/wiki-llm
```

Then just ask: *"build a wiki LLM from these PDFs"* and the skill activates.

**Other agents:** copy the skill folder into your agent's skills directory (e.g. `~/.agents/skills/` for Codex), or point your agent at `skills/wiki-llm/SKILL.md`.

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, share it.
