You are an AI coding agent. The human who owns this machine wants their own version of this skill. Follow these steps in order. Do not skip the steps that require you to look at images.

## 0. Confirm you can do this

**Goal: Prove that at least one image generation path is available before changing anything.**

Prerequisites are a working coding agent, `python3`, the ability to inspect local image files, and either:

- A reachable model router with `MODEL_ROUTER_KEY` configured and at least one supported image model.
- A logged-in Codex CLI whose host provides a built-in image generation tool.

From the skill root, run this first and paste the complete output into your working notes:

```sh
sh scripts/doctor.sh
```

The router path also uses `curl` for OpenAI requests. If the doctor reports that no generation path is available at all, stop. Tell the human exactly what is missing. Ask them to install and log in to Codex, or configure a reachable model router and set `MODEL_ROUTER_KEY`. Do not proceed on the assumption that generation will become available later.

**VERIFY:** The pasted doctor output shows at least one available path: router OpenAI, router Google, or built-in Codex.

## 1. Install the skill

**Goal: Put the whole skill folder where the host agent can discover it.**

Choose the host that the human uses. Run the matching commands from the directory that contains the `generate-me` folder.

For Claude Code:

```sh
mkdir -p "$HOME/.claude/skills"
rm -rf "$HOME/.claude/skills/generate-me"
cp -R "generate-me" "$HOME/.claude/skills/generate-me"
```

For Codex:

```sh
mkdir -p "$HOME/.codex/skills"
rm -rf "$HOME/.codex/skills/generate-me"
cp -R "generate-me" "$HOME/.codex/skills/generate-me"
```

For a generic coding agent, give the agent the skill entry point directly:

```sh
printf 'Use this skill file: %s\n' "$(pwd)/generate-me/SKILL.md"
```

Copy the folder whole. Do not copy only `SKILL.md`. The scripts resolve the references, assets, and output paths relative to their own installed locations.

**VERIFY:** In the chosen installation, `SKILL.md`, `SETUP.md`, `scripts/generate.py`, and `scripts/doctor.sh` all exist under the same `generate-me` folder.

## 2. Collect the photos

**Goal: Obtain enough clear, varied source photos to identify the person reliably.**

Read `references/photo-guide.md`. Then ask the human for about five current photos that follow that guide. Ask them to provide the photos as local file paths. Do not infer paths, search private folders without permission, use social media copies, or substitute generated images.

Wait for the human to supply the paths. Do not guess what they look like and do not create an identity profile before receiving the files.

**VERIFY:** You have readable local paths for about five human-supplied photos, and each path opens as an image.

## 3. LOOK at every photo

**Goal: Visually inspect the source material and assign the strongest photos to the correct identity slots.**

This step is mandatory and cannot be delegated to a blind worker. Open every image with your own image-viewing capability and actually examine it. Compare angle, sharpness, lighting, expression, framing, and how much of the person is visible.

Reject a photo and ask for a replacement if it is blurry, filtered, obstructed, a close wide-angle selfie, or AI-generated. Do not quietly use a weak photo merely to fill a slot.

Assign the best accepted photos to these filenames, preserving `.jpeg` or `.png` according to the copied file:

1. `assets/identity-default/01-primary-face.jpeg` or `.png`, the clearest neutral or natural face reference.
2. `assets/identity-default/02-upper-body.jpeg` or `.png`, a clear head-and-torso reference.
3. `assets/identity-default/03-proportions.jpeg` or `.png`, the best view of overall body proportions and posture.
4. `assets/identity-default/04-expression-open-smile.jpeg` or `.png`, a clear open-smile expression reference.
5. `assets/identity-default/05-secondary-face.jpeg` or `.png`, a second useful face angle or lighting condition.

Use copies when the human may need the originals. Remove stale files for the same slot before placing the selected copy. Move narrow-purpose shots, such as a hand detail or a special accessory reference, to `assets/support-only/`. Such shots must not replace the default identity slots.

**VERIFY:** List every final slot filename and state in one line why that inspected photo earned that slot. Also list any rejected or support-only photo and the reason for that decision.

## 4. Write the identity profile

**Goal: Turn visible, repeatable identity traits into a precise reusable prompt block and QA standard.**

Create the working profile from the template:

```sh
cp "references/identity-profile.template.md" "references/identity-profile.md"
```

Fill EVERY `{{PLACEHOLDER}}` by describing what you actually observe across the accepted photos. Describe observed features factually and respectfully. Do not flatter, do not use euphemisms, and do not guess anything that is not visible. Vague descriptions produce a generic face that does not look like the person.

Keep stable traits separate from scene-dependent details. Record visible face shape, feature geometry, hair, skin appearance, build, proportions, and distinctive visible details only when the photos support them. Use they/them unless the human states their pronouns.

**VERIFY:** Run the following command and confirm it prints nothing and exits with no matches:

```sh
if grep -n '{{' "references/identity-profile.md"; then
  echo "FAIL: unfilled placeholders remain"
else
  echo "OK: zero identity-profile placeholders remain"
fi
```

## 5. Fill the remaining placeholders

**Goal: Remove every template token from the installed skill.**

Search the whole skill folder for `{{` tokens. Fill each one using information the human actually supplied. This may include a token such as `{{OWNER_NAME}}` in `agents/openai.yaml`. Ask the human when a required value is unknown. Never invent personal details.

```sh
grep -R -n '{{' .
```

Do not alter the double-brace examples in setup documentation while using a source template. In the personalized installed copy, replace or remove template examples as needed so the final search is clean.

**VERIFY:** From the skill root, a repo-wide `grep -R -n '{{' .` returns nothing.

## 6. Run the first test

**Goal: Produce two contrasting scenes through both router providers for a useful comparison.**

With `MODEL_ROUTER_KEY` set, run this exact command from the skill root:

```sh
python3 scripts/generate.py \
  --provider both \
  --scene "portrait-test=Photoreal head-and-shoulders portrait, soft window light, neutral background, natural skin texture, direct eye contact" \
  --scene "stylized-test=Stylized editorial illustration with bold geometric color fields, expressive lighting, and a clean magazine-cover composition" \
  --out "output/first-test"
```

The provider-and-scene jobs run concurrently. Google normally returns much sooner, while OpenAI can take roughly 90 seconds. A slow OpenAI result is not by itself a failure. Wait for the process to finish and inspect `output/first-test/results.json` for the recorded outcome of every job.

**VERIFY:** At least one real image file exists, has nonzero bytes, and has a matching successful record in `output/first-test/results.json`. For a full comparison, verify that both provider filenames exist for both scene slugs.

## 7. LOOK at the results and grade them

**Goal: Evaluate identity fidelity and image quality with visual evidence, not filenames or API success alone.**

Open every generated image with your own image-viewing capability. Read the Pre-delivery QA checklist in `references/identity-profile.md`, then score each image against every item. Pay special attention to the stable facial geometry, hair, proportions, expression behavior, unwanted beautification, accidental accessories, malformed anatomy, and scene compliance.

Do not delegate this step to a text-only worker. An API success means only that bytes were returned, not that the image resembles the person.

**VERIFY:** For each generated filename, state which Pre-delivery QA checks passed and which failed. Give one brief visual observation for every failed check.

## 8. Fix one round

**Goal: Correct the smallest identified fidelity problem and test the correction once.**

If a check failed, revise only the failing trait in the identity profile or the scene prompt. Prefer a factual profile correction when the same identity trait failed across scenes. Prefer a prompt correction when only the requested scene or styling failed. Then regenerate the affected scene once and compare it with the first result.

Never feed a generated image back in as an identity reference. Generated errors compound and can replace real traits with model artifacts. The files in `assets/identity-default/` must remain human-supplied source photos.

**VERIFY:** Record the one trait changed, the exact file or prompt changed, and whether the regenerated image fixed that check without breaking checks that previously passed.

## 9. Hand it over

**Goal: Leave the human with a working personalized skill and a simple repeatable command.**

Tell the human:

- What files you added or personalized.
- Which source photos occupy each identity slot.
- Which provider looked better on their face in the test, based on the QA checklist.
- Any known limitation that remained after the one allowed correction round.

Give them this one-line command for future router generation:

```sh
python3 scripts/generate.py --provider both --scene "my-image=REPLACE THIS WITH THE SCENE YOU WANT"
```

Explain that the files appear in `output/`, with one provider-labeled image per successful provider and a machine-readable `results.json` report.

**VERIFY:** The human receives the summary, the provider recommendation, the output location, and the copy-paste one-line command.

## If you only have Codex and no router

Use the host agent's built-in image generation tool instead of `scripts/generate.py`. Attach the real identity photos as referenced image paths, in the authority order `02-upper-body`, `01-primary-face`, `03-proportions`, `04-expression-open-smile`, `05-secondary-face`, with at most five references. Include the reusable prompt block from `references/identity-profile.md` and the requested scene in the generation prompt.

The built-in tool writes into its own cache folder first. After generation, locate the real generated file and move or copy it to the intended destination under this skill, such as `output/my-image--codex-built-in.png`. Do not claim the destination exists until you have checked it. Never create a placeholder image.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `doctor.sh` reports the router unreachable | Confirm the router process is running, verify `MODEL_ROUTER_URL`, check local network or firewall access, then rerun `sh scripts/doctor.sh`. |
| The router key is not set | Set `MODEL_ROUTER_KEY` in the current shell or approved secret manager. Never paste it into a script or commit it to the skill. |
| Fewer than two photos are found | Inspect the supplied photos, then place at least two accepted files in `assets/identity-default/` using the exact slot stems and `.jpeg` or `.png` extensions. |
| Placeholders are still present | Run `grep -R -n '{{' .`, open every reported file, and replace each token with observed or human-supplied information. |
| One provider returns an error while the other succeeds | Keep the successful real image, read that provider's error in `results.json`, check that its model is listed by the router, and retry only after correcting the reported cause. Partial success is still useful. |
| The generated face does not look like the person | Make the identity profile more specific about the observed trait that failed. Do not merely make the scene prompt longer, and do not use a generated image as a new identity reference. |
