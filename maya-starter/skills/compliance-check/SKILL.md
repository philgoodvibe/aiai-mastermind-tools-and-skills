---
name: compliance-check
description: Run a content draft against the compliance knowledge base in brain/compliance/ and return PASS or FAIL with exact concerns. Use on every draft before it reaches output/drafts/ or Mai Marketing Machine, and whenever the owner says "compliance check", "is this compliant", or "check this post". No draft proceeds without a PASS from this skill.
---

# Compliance Check

This is the gate. Every draft (caption, text on image, and visual concept) passes through here before it goes anywhere near Mai Marketing Machine. A post that embarrasses the owner with their carrier or their state regulator costs more than a month of content earns. When in doubt, fail it and ask.

## Step 1: Load the law

Read `brain/compliance/compliance-knowledge-base.md` in full. That file is the only source of rules. Do not invent rules that are not written there, and do not waive rules that are. If the draft raises a question the file does not answer, stop and ask the owner, then write the answer into the knowledge base before ruling.

## Step 2: Scan the complete draft

Check all three surfaces:

1. The caption, line by line
2. The text on the image (hooks on visuals are the most-seen words in the post)
3. The visual concept itself (what the image implies: fear-mongering, a competitor's branding, a person who is not the owner)

## Step 3: Test against every rule category

Walk the knowledge base top to bottom. At minimum:

- Absolute claims about a stranger's coverage or price ("you are overpaying" must read "you might be overpaying")
- Poaching language ("switch to us" must read like "give us a call and we will help you review")
- Guarantees, superlatives, "always," "never," "best," "cheapest"
- Pricing, premiums, percentages, or savings amounts
- Competitor or carrier named negatively, or implied identifiably
- Carrier-specific rules (section 2), state and licensing rules (section 3), agency red lines (section 4)
- Banned phrases log (section 6): exact and near matches
- Stories: real, names removed. Any personal story must trace to brain/voice/story-bank.md. If that file does not exist, no personal story should appear; an invented anecdote is a FAIL
- Client language used where the brain calls for it

## Step 4: Rule and report

Produce a verdict in this format and record it in the draft's post.md under Compliance record:

```
VERDICT: PASS | FAIL
Checked: caption, image text, visual concept
Rules applied: [sections of the knowledge base that were relevant]

If FAIL, for each finding:
- Location: [the exact sentence or image text]
- Concern: [the specific rule it breaks, quoted from the knowledge base]
- Suggested rewrite: [compliant alternative that keeps the hook strength]
```

## Step 5: Route the result

- **PASS:** stamp post.md with `Compliance: PASS (date)`. The draft may proceed to `output/drafts/` and the posting-mmm skill.
- **FAIL:** send the draft back to the skill that created it with the exact concerns and suggested rewrites. Never silently rewrite and pass your own fix in the same breath: the lane skill revises, and the revision comes back through this gate. Only a PASS proceeds. There is no third outcome.

## Step 6: Learn

When the owner overrules or refines a ruling, or catches something this check missed, append the lesson to the approved-phrases bank or the banned-phrases log in the knowledge base the same day. The gate gets smarter or it gets useless.
