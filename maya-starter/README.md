# MAYA Starter Kit

This is the starter folder for **Your Automated Social Media Content Team**, the AIAI Mastermind course. It is the home base for MAYA, the AI agent that runs your content team, and for Codex, the copywriter and designer MAYA manages.

You do not run this kit by hand. You hand it to MAYA, and MAYA builds your content team inside it. You talk to MAYA in the Claude Code panel docked on the right side of VS Code, not in a terminal. The terminal is used once, during setup, to install the Claude Code and Codex tools. After that, every conversation with MAYA happens by typing into the Claude Code panel.

## Get this kit

The simplest way, no terminal needed:

1. On the GitHub page for this kit, click the green **Code** button, then **Download ZIP**.
2. Unzip it, and open the unzipped folder in VS Code (File, Open Folder).

If you are comfortable with git, you can `git clone` the repository instead. Either way, you end up with this folder open in VS Code.

## 60-second setup

1. Get this kit (Download ZIP above) and open the folder in VS Code.
2. Drop your `My_Agency_Context.md` into `brain/`.
3. Drop 5 to 10 clear photos of yourself into `skills/image-brand/face-reference/`.
4. Open `JOB-DESCRIPTION.md`, fill in every `[BRACKET]`, and paste the whole thing into the Claude Code panel.
5. Step away for 15 to 20 minutes while MAYA builds. Silence and new files are normal.

That is the short version. The full walkthrough, with checkpoints for every step, is in the course: **Your Automated Social Media Content Team**, Module 3 (Hire and Brief MAYA). If you have not finished the Your 1st AI Employee course and the My Agency Context document, go do those first. This kit assumes both.

## Folder map

```
maya-starter/
  README.md             You are here
  JOB-DESCRIPTION.md    The kickoff brief you paste into Claude Code
  CLAUDE.md             MAYA's standing instructions (identity, pipeline, rules)
  brain/                Everything MAYA knows about your business
    My_Agency_Context.md   You add this (from the Agency Setup Assistant)
    compliance/            Carrier-safe language rules
    voice/                 Your voice profile (required) and story bank (optional)
  skills/               What MAYA knows how to do
    newsjacking/           Ride the news your clients are watching
    problem-solution/      Turn real client complaints into posts
    entertain-meme/        Humor that earns the follow
    compliance-check/      The gate every draft passes before it ships
    posting-mmm/           Push drafts to Mai Marketing Machine
    image-brand/           On-brand visuals with your face only
    daily-run/             Fire all three lanes once and stage drafts for review
  output/               Where drafts land and move through review
    drafts/  approved/  posted/
```

## What good looks like

When the build is done and trained, MAYA runs a daily pipeline: pick a content lane, research, write hooks and copy in your voice, generate an on-brand image, pass compliance, and place a draft in Mai Marketing Machine for your review. Your job becomes a 10-minute morning edit, not a content grind.

Once the end-to-end test passes, you put it on autopilot. The daily-run skill fires all three lanes on a daily schedule, stages one draft per lane in Mai Marketing Machine, and your only daily job is to open Mai Marketing Machine, review the drafts, and approve. After about a month of trusting those drafts, you can graduate MAYA to auto-publish. See CLAUDE.md, "Daily run and graduation."

Questions or stuck? Post a screenshot in the AIAI community and tag the team.
