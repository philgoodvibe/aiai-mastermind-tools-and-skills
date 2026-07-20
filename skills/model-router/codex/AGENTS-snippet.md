# SolFab section for ~/.codex/AGENTS.md
# (the installer appends the block below; kept here as the canonical copy)

## SolFab - hand build briefs to Claude Fable

When the user says "solfab" (or asks for a build and wants the SolFab
pipeline), do not build it yourself. Use the `solfab` skill: run

    bash ~/.claude/model-router/scripts/solfab.sh "<brief, verbatim + context>" "<absolute project dir>"

in the foreground with a long timeout (15+ minutes), then relay Claude
Fable's final report faithfully. Fable orchestrates and delegates the
building to GPT-5.6 Sol through the local proxy. If the brief is ambiguous,
ask the user BEFORE dispatching - Fable runs headless and cannot ask.
