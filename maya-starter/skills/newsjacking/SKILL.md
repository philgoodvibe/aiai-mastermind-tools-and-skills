---
name: newsjacking
description: Create a social post that rides a current news story or viral moment the agency's ICP is already paying attention to, with an insurance angle for the agency. Use when the daily lane is newsjacking, or when the owner says "newsjack", "what's in the news", "ride this story", or names a current event to post about. Requires brain/My_Agency_Context.md.
---

# Newsjacking

Take what is already winning the ICP's attention and attach the agency's point of view to it. The news supplies the hook energy. You supply the insurance angle and the brand. Speed matters: a newsjack that ships two days late is a regular post.

## Step 1: Read the brain

Read `brain/My_Agency_Context.md` (WHO I SERVE, MY COMMUNITY, MY BRAND, agency name and contact) and skim `brain/voice/voice-profile.md`. You are looking for what this specific audience watches, celebrates, and worries about, including culturally specific events the general news ignores.

## Step 2: Find candidate stories

Search the web for today's stories in two buckets:

- **Local:** the agency's city, region, and the ICP's community. Local weather events, sports, festivals, business news, anything the ICP would mention at dinner.
- **National and international:** only if it is genuinely viral and the ICP cares. Major sports (World Cup, playoffs), big cultural moments, widely shared consumer news.

Collect 3 to 5 candidates with source links. Skip anything involving active tragedy where an insurance angle would read as ambulance-chasing, and skip politics and religion unless the brain explicitly allows it.

## Step 3: Score and pick one

Score each candidate 1 to 5 on:

1. Is the ICP already watching this without us?
2. Emotional charge (excitement, pride, suspense, humor)
3. Is there a natural, non-forced insurance angle?
4. Visual potential (can one image tell it?)
5. Timeliness (is it peaking today or tomorrow?)

Pick the winner. If nothing scores well, say so and suggest swapping today's lane rather than forcing a weak newsjack.

## Step 4: Build the insurance angle

Connect the story to what the agency does for the ICP. The angle must pass the dinner-table test: would a client hear it and nod, not groan? Pattern: the story's tension maps to a coverage truth. A goalkeeper saves what others let through. A backup player nobody noticed wins the match. Find the one-line bridge, then check it against the value proposition in the brain.

## Step 5: Write hooks

Write 3 to 5 hook options, 5 to 10 words each, that lead with the news, not with insurance. The hook is 80 percent of the effort. Choose the strongest and note the runners-up in post.md.

## Step 6: Find reference images

Web search for images of the actual event: the actual teams playing today, the actual local landmark, the actual moment. Do not reuse copyrighted photos in the post. Instead, capture what makes them recognizable (jersey colors, setting, composition) and feed that description to the image-brand skill so the generated visual is specific to the real event. A generic soccer ball converts worse than the two teams actually playing that day.

## Step 7: Draft the post

Write the caption using the post.md template in `output/README.md`. Structure: Interest (the news hook), Inform (the angle, in the owner's voice, plain language), Invite (CTA with agency name and contact). Keep it Instagram-length: hook in the first line, under 150 words, 3 to 5 hashtags.

## Step 8: Hand off

1. Call the **image-brand** skill with the visual direction and reference notes from steps 6 and 7.
2. Run the **compliance-check** skill on the complete draft.
3. On PASS, create the post folder in `output/drafts/` and proceed to **posting-mmm**. On FAIL, revise per the exact concern and re-check.
