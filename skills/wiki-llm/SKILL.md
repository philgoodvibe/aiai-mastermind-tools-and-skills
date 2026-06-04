---
name: wiki-llm
description: Use when someone wants to turn a collection of source documents (books, PDFs, papers, articles, transcripts) into a compounding, interlinked Obsidian knowledge base maintained by an LLM — a "wiki LLM" / second brain / Memex that sits between them and the raw sources. Triggers on "wiki llm", "build a wiki from these books/PDFs", "ingest these sources", "compounding knowledge base", "Obsidian vault from documents", "RAW / WIKI / OUTPUT structure", or Karpathy's llm-wiki idea. Domain-agnostic (insurance, research, a book, a company, a hobby).
---

# Wiki LLM (Karpathy-style compounding knowledge base)

## Overview

Most "LLM + documents" setups are RAG: retrieve chunks at query time, re-derive the answer from scratch every time, accumulate nothing. A **wiki LLM** is the opposite — the LLM reads each source once and **compiles** it into a persistent, interlinked set of markdown pages that sit *between* the human and the raw sources. The cross-references, contradictions, and synthesis are already there; every new source makes the wiki richer.

**Core principle:** The wiki is a persistent, compounding artifact, not a query-time reconstruction. The LLM writes and maintains every page; the human curates sources, explores, and asks questions. Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase. (Idea: Andrej Karpathy's `llm-wiki`.)

This skill is **domain-agnostic** — the same architecture works for a P&C insurance agency, a research thesis, a single novel, a company's internal knowledge, or a hobby deep-dive. Only the page-type vocabulary and the schema's purpose change.

## When to use

- The user has a folder of sources and wants organized, cross-linked, *cumulative* knowledge — not one-shot summaries.
- They mention Obsidian, a "second brain", a "wiki", a knowledge base, or Karpathy's idea.
- They'll keep adding sources over time and want the maintenance burden near zero.

**When NOT to use:** a single one-off summary; a pure Q&A over docs where nothing is kept (that's RAG); project source code (use CLAUDE.md).

## The three-layer architecture (always)

| Layer | Folder (rename to taste) | Owner | Rule |
|---|---|---|---|
| **Raw sources** | `Raw/` | human curates | **immutable** — the LLM reads, never edits |
| **The wiki** | `Wiki_LLM/` | LLM writes | **extraction only** — what the sources say + how they relate |
| **Output** | `Output/` | LLM writes | **synthesis/editorial** — anything the LLM argues, recommends, or produces |
| **Memory** | `.memory/` | LLM writes | cross-session memory, travels with the repo |
| **Schema** | `CLAUDE.md` (+ byte-identical `AGENTS.md`) | co-evolved | the operating manual; read first every session |

**The hard boundary is the whole game:** the wiki must stay pure extraction so it can be *cited* as the substrate of any synthesis. The moment a page editorializes ("X should do Y", "the corpus collectively argues…"), it belongs in `Output/`. Use a `> Editorial:` marker for synthesis claims and keep it out of the wiki.

## Page types (configure per domain)

Default set for a book/document corpus — rename for other domains:
- `sources/` — one page per document (the summary that links everything).
- `authors/` — one page per person/author (or `entities/` for orgs, characters, etc.).
- `concepts/` — one page per idea/theme.
- `frameworks/` — one page per named model/system.
- Plus `index.md` (catalog), `log.md` (append-only chronological), `_templates/`.

Folder choice rule: person→authors, named model→frameworks, idea→concepts, a specific document→sources.

## Instantiation workflow (setting up a NEW wiki)

1. **Locate the prior convention.** If the user has built a wiki LLM before, find and reuse its `CLAUDE.md`, templates, and `.obsidian/` config so the new one is consistent. Otherwise start from `templates/` in this skill.
2. **Confirm the three layers + names** and the domain's page-type vocabulary.
3. **Write the schema** (`CLAUDE.md`, mirrored to `AGENTS.md`): purpose, the hard wiki/output boundary, page-naming (lowercase-hyphenated), frontmatter rules, wikilink discipline, ingest/query/lint operations, the Raw-traceback protocol. Start from `templates/CLAUDE.md.template`.
4. **Write the templates** (`source/author/concept/framework` + an `Output/synthesis`). Copy from `templates/`, adapt sections to the domain.
5. **Set up Obsidian-friendliness** (see below) from `templates/obsidian/`.
6. **Pre-populate `index.md`** with the full source catalog (you usually know all filenames up front), and seed `log.md`.
7. **Ingest** (below), then build the synthesis layer (authors/concepts/frameworks) **from the source pages**.

## Obsidian-friendliness (required — "properties, color-coded, graphical")

- **Frontmatter on every page** (YAML) → shows in Obsidian's Properties panel and drives Dataview. Always: `title, type, cssclasses, tags, created, updated` + type-specific fields.
- **`cssclasses: [<type>]`** + a CSS snippet (`.obsidian/snippets/wiki-colors.css`) color-codes each page type in note view (accent bar + tinted properties block).
- **`.obsidian/graph.json` color groups** — one color per page-type folder, so the graph reads at a glance; optional second-axis "notebook" tint by a frontmatter field. Color legend goes in `README.md`.
- **Wikilink discipline** — `[[slug]]` for every entity reference, no bare names; link first occurrence per section; aim for bidirectional density. **Ghost links** (links to not-yet-written pages) are good — they surface gaps in the graph for the next lint.
- `app.json`: `useMarkdownLinks: false`, `newLinkFormat: shortest`, ignore `_templates/`.

## Ingesting at scale (the parallel pattern)

For a big drop (dozens of PDFs), fan out: one subagent per source, each (a) extracts text (`pdftotext -layout`; count form-feed `\f` for page numbers; OCR scanned PDFs), (b) writes ONE source page from the template with page-cited quotes, (c) returns compact structured metadata. **Subagents write only their own source page — never the index, log, or shared pages** (concurrent writes race). Then build the synthesis layer (authors/concepts/frameworks) in a second wave that reads the *source pages* (not the PDFs) — cheap, fast, and the compounding principle in action. The orchestrator alone rewrites `index.md` and `log.md`.

A typical single ingest touches 8–15 pages. Fewer than 5 → under-linking; more than 25 → over-fragmenting.

## Raw-traceback (keep the wiki trustworthy)

The wiki is the working surface; the raw files are the verbatim backstop. Put a `source-pdf:`/`source-file:` field in each source page's frontmatter. Quotes are short and page-cited (`> "quote" — *[[slug|Title]]*, p.N`); the full passage stays in `Raw/` and is reachable with `pdftotext -f N -l N`. Only open a raw file for a longer/exact quote or to verify.

## Operations (document these in the schema)

- **Ingest** — read source → write source page → create/update author/concept/framework pages → update `index.md` → append `log.md` (`## [YYYY-MM-DD] ingest | Title`).
- **Query** — read `index.md` first, follow `[[wikilinks]]`, answer with citations; file substantive answers into `Output/` so explorations compound.
- **Lint** — periodically scan for contradictions, orphans, ghost links, sparse/stale pages; write the report to `Output/`.

## Common mistakes

| Mistake | Fix |
|---|---|
| Editorializing in the wiki | Move it to `Output/`; wiki is extraction only |
| Subagents all writing `index.md`/`log.md` | Only the orchestrator writes shared files; subagents write their own page |
| Bare names instead of `[[wikilinks]]` | Link every entity; ghost links are fine |
| Re-reading PDFs to build concept pages | Build the synthesis layer from the source pages |
| Slug collisions (book "Positioning" vs concept "positioning") | Disambiguate one slug (e.g. `positioning-the-battle-for-your-mind`) |
| Fabricated quotes/page numbers | Verbatim only, with page from form-feed counting; else omit |
| One giant batch, no log | Log each ingest; the log is the audit trail |

## Files in this skill

- `templates/CLAUDE.md.template` — the schema, with `{{PLACEHOLDERS}}` to fill per project.
- `templates/source.md`, `author.md`, `concept.md`, `framework.md`, `synthesis.md` — domain-agnostic page templates.
- `templates/obsidian/` — `graph.json`, `app.json`, `appearance.json`, `snippets/wiki-colors.css` ready to drop into `.obsidian/`.

Validated by building a 174-page wiki (45 books → sources + 52 authors + 26 frameworks + 51 concepts) for a P&C insurance agency in one session.
