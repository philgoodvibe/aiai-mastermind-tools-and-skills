---
name: image-brand
description: Generate on-brand post visuals through Codex CLI's built-in image generation, using the agency's exact brand colors and the owner's face reference photos. Use whenever a post needs an image, carousel slides, or a visual revision, or when the owner says "generate the image", "make the visual", or gives image feedback. Only the owner ever appears in generated images.
---

# Image and Brand

Codex is the designer on this team, and you are the creative director. Codex only does great work when the brief is exact: precise hex codes, real reference photos, one named emotion, and the exact text that goes on the image. This skill is that brief, every time.

## Hard rules (read before every generation)

1. **Only the owner appears in generated images.** The only face source is `skills/image-brand/face-reference/`. No staff, no clients, no invented people presented as real. If a concept needs a crowd, use silhouettes, illustration, or objects instead.
2. **Exact brand colors only.** Read the hex codes from the MY BRAND section of `brain/My_Agency_Context.md` and pass them verbatim into the prompt. "Blue-ish" is not a brand.
3. **Every visual is emotional and eye-catching first.** A technically correct but flat image fails. Name the one emotion before you write the prompt.
4. **Text on image is the hook**, 5 to 10 words, readable on a phone in one second.

## Step 1: Assemble the brief

From the lane skill's handoff and the brain, collect:

- Concept: one sentence, what the image shows
- Emotion: one word (pride, relief, suspense, laughing-with)
- Text on image: the exact hook words
- Brand: hex codes, fonts or font feel, and visual style notes from MY BRAND
- Owner in frame? If yes, pick the 2 or 3 clearest face-reference photos for the pose and angle needed
- Reference notes: for newsjacking, the recognizable specifics of the real event (jersey colors, setting) gathered by web search
- Size: 1080x1080 square or 1080x1350 portrait for Instagram feed; one image per carousel slide

## Step 2: Generate through Codex CLI

Call Codex non-interactively with the face references attached as image inputs and a complete prompt. Pattern:

```bash
codex exec \
  -i "skills/image-brand/face-reference/<photo-1>.jpg" \
  -i "skills/image-brand/face-reference/<photo-2>.jpg" \
  "Use your built-in image generation tool. Generate a 1080x1350 social media
  image. The person in the attached reference photos is the agency owner;
  match their face and likeness exactly, but not their clothing. Scene:
  [concept]. Emotion: [emotion]. Text on the image, large and high-contrast:
  '[hook text]'. Brand colors, use these exact hex values: [#......, #......].
  Style: [MY BRAND style notes]. Footer strip: [Agency Name] | [contact].
  Save the result to output/drafts/<post-folder>/image-1.png"
```

If the owner is not in the concept, drop the `-i` flags and the likeness line. If Codex CLI is unavailable or errors, stop and tell the owner; do not substitute another image source without approval.

## Step 3: Review like a creative director

Before attaching the image to the draft, check:

- Does it land the named emotion at thumbnail size?
- Is the hook text readable on a phone, and spelled exactly right?
- Are the brand colors actually the brand colors?
- Does the owner look like the owner? Reject uncanny or off-likeness results and regenerate with different reference photos.
- Is the agency footer present and legible?
- For newsjacks: is it specific to the real event, not generic?

Regenerate until it passes. Two or three rounds is normal.

## Step 4: Deliver

Save final images into the post folder (`image-1.png`, `image-2.png`, ... in slide order) and record the text-on-image and visual direction in post.md. The full draft then goes to compliance-check, which reviews the image text and concept too.

## Feedback is training

When the owner reacts to an image ("more emotion", "too corporate", "my face looks off", "make it about the actual team playing"), apply the fix, then write the lesson into this file as a new bullet under Hard rules or Review, so the next brief starts smarter.
