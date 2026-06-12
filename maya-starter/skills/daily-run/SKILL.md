---
name: daily-run
description: Run all three content lanes once in a single pass and stage one draft per lane in Mai Marketing Machine for owner review. Use when the owner says "daily run", "run the daily", "make today's posts", "fire all the lanes", or when a scheduled daily run triggers. Produces one newsjacking draft, one problem-solution draft, and one entertain draft, each compliance-checked and staged as a DRAFT. Respects the publishing mode toggle in CLAUDE.md.
---

# Daily Run (All Lanes)

This skill is autopilot. One command fires all three content lanes, produces one draft per lane, gates each through compliance, and stages each as a DRAFT in Mai Marketing Machine. The owner's daily job becomes a 10-minute review in Mai Marketing Machine, nothing more.

Before you start, read the **Publishing mode** toggle in CLAUDE.md ("Daily run and graduation"). While it reads DRAFT-FIRST, you stage drafts only and never schedule or publish. While it reads AUTO-PUBLISH, you may schedule and post on your own at the agreed times. Compliance-check gates every post in both modes.

## Step 1: Read the context

Read `brain/My_Agency_Context.md` and `brain/voice/voice-profile.md` once at the start so all three lanes share the same grounding. Note whether `brain/voice/story-bank.md` exists. If it does, personal-story posts are available. If it does not, that is fine: skip personal-story angles and work from the voice profile and agency context. Do not invent stories to fill the gap.

## Step 2: Run the three lanes, one draft each

Run each lane skill in turn, producing exactly one draft per lane:

1. **newsjacking** - one draft. Follow the newsjacking skill end to end.
2. **problem-solution** - one draft. Follow the problem-solution skill end to end.
3. **entertain-meme** - one draft. Follow the entertain-meme skill end to end.

Each lane does its own research, hooks, copy, and image-brand handoff exactly as its SKILL.md describes. Do not shortcut the lanes; the only difference today is that all three run in one pass instead of one per day. If a lane genuinely has no strong material (for example newsjacking finds nothing the ICP cares about today), say so plainly and skip that lane rather than shipping a weak post. Aim for three drafts, accept fewer when the material is not there.

## Step 3: Compliance-check every draft

Run the **compliance-check** skill on each draft separately. A FAIL goes back to the lane that created it with the exact concern, gets revised, and comes back through compliance. Only a PASS proceeds. There is no third outcome, and the daily run does not lower the bar.

## Step 4: Stage each draft in Mai Marketing Machine

For every draft that passes compliance, create its post folder in `output/drafts/` per `output/README.md`, then run the **posting-mmm** skill to stage it as a DRAFT in Mai Marketing Machine. Three passing drafts means three staged drafts.

While the publishing mode is DRAFT-FIRST, stop at DRAFT. Never schedule or publish. While the mode is AUTO-PUBLISH, you may proceed to schedule each post at the agreed times per the posting-mmm skill.

## Step 5: Report

Give the owner one short summary of the run:

- One line per lane: lane, the angle, compliance result, staged or skipped.
- Where to review: Mai Marketing Machine, Marketing tab, Social Planner, Drafts.
- Anything you skipped and why.

Keep it tight. The owner wants to know what is waiting for them and nothing more.

## Putting the daily run on a schedule

The goal is for this to fire on its own every day, so the owner never has to remember to type "daily run". There are two paths.

### Simplest path: ask MAYA to set it up

In the Claude Code panel, tell MAYA: "Set up my daily run to fire automatically every morning at [time]." MAYA configures a scheduled run for you, confirms the time, and tells you how to check it and how to turn it off. This is the recommended path for most owners. You do not touch the terminal.

### What it does under the hood

A scheduled daily run is just a small recurring job that opens this kit and runs the daily-run skill at a set time each day. At a high level:

- **On a Mac**, the schedule is a recurring task managed by the operating system (a launchd job, or a cron entry). It runs once a day at the time you chose, in this project folder, invoking MAYA with the daily-run instruction. MAYA does the work, stages the drafts, and exits.
- **On Windows**, the same thing runs as a Task Scheduler task: a daily trigger that opens this kit and runs the daily-run skill.

You do not need to write any of this by hand. Ask MAYA to set it up (the simplest path above) and it handles the scheduling details, including reading the Mai Marketing Machine credentials from the keychain at run time. No keys ever go into the schedule or any file.

### After it is scheduled

Each morning, the run lands fresh drafts in Mai Marketing Machine before you sit down. Your only job, while the publishing mode is DRAFT-FIRST, is to open Mai Marketing Machine, review the drafts, and approve and submit the ones you want. After about a month of trusting the drafts, flip the publishing mode to AUTO-PUBLISH in CLAUDE.md and the daily run will schedule and post on its own while you spot-check. See CLAUDE.md, "Daily run and graduation," for the toggle and the graduation rule.
