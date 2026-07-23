---
name: generate-me
description: Generate an image of "me", "my face", "make me", "put me in", "turn me into", or a photo of the skill owner while preserving their facial identity across photoreal, illustrated, cartoon, cinematic and stylized scenes.
---

# Generate Me

## Before you use this

If `references/identity-profile.md` still contains `{{PLACEHOLDER}}` tokens, or `assets/identity-default/` has no photos, this skill is not yet customized. Run `SETUP.md` first and tell the owner that setup is required. Do not generate a generic person as a substitute.

## Required preparation

1. Resolve the skill directory from the location of this `SKILL.md`. Use that resolved directory for every relative path below.
2. Read `references/identity-profile.md` before writing a prompt or selecting images.
3. Treat every bundled photo as a reference. Never treat a bundled photo as an edit target unless the owner explicitly asks to alter that exact photo.

## Reference selection

Image tools commonly impose a five-image limit. Every edit target and every style reference counts toward that limit, so subtract those images before choosing identity references.

The identity slots are:

- Slot A, `primary-face`, for clear facial structure and fine features.
- Slot B, `upper-body`, for the strongest overall balance of likeness, posture and build.
- Slot C, `proportions`, for body proportions, stance and scale.
- Slot D, `expression-open-smile`, for teeth and broad open-smile behavior.
- Slot E, `secondary-face`, for a second view of stable facial geometry.

The default authority order is B, A, C, D, E. Use the following fallback ladder after accounting for edit targets and style images:

- Four identity slots: B, A, C, D.
- Three identity slots: B, A, C.
- Two identity slots: B, A.
- One identity slot: B.

Keep at least two identity references whenever possible. If a request depends on a specific trait, such as an open smile, substitute the relevant slot for the lowest-priority available slot. Do not exceed the tool's total image limit.

## Support-only assets

`assets/support-only/` holds photos useful for one narrow purpose, such as eyewear detail or a deliberately exaggerated expression. Use a support-only image solely for its labeled purpose. Never use it to infer or judge facial geometry, head shape, feature spacing or general likeness.

## Prompt construction

Start with the owner's requested concept, composition and style. Then append a compact identity block derived from `references/identity-profile.md`.

The prompt must:

- State that preserving the owner's identity is the highest priority.
- Specify the requested expression, using the profile's matching expression clause.
- Request a natural eye-level portrait perspective unless the owner asks for another viewpoint.
- Prohibit beautifying or genericizing the face.
- Prohibit changing apparent age or body proportions.
- Prohibit plastic-smoothing the skin.
- Prohibit adding or removing hair that the profile does not describe.

Do not overload the prompt with repeated facial adjectives. The photos carry identity. The text should stay compact and mainly prevent known failure modes.

## Generation workflow

1. Make one generation call per scene.
2. Keep the face large enough to read clearly whenever likeness matters.
3. Lock facial geometry and identity before applying the requested style.
4. Require anatomically natural limbs, joints, hands and finger counts when arms or hands are prominent.
5. Inspect the saved local output after generation.
6. Run the pre-delivery QA checklist in the identity profile.
7. If likeness or anatomy fails, regenerate once. Correct only the failed traits instead of rewriting or intensifying the entire prompt. Do not accept a near match as an exact match.

## Generation paths

Both paths are first-class and supported.

### Path 1, model router

Run `scripts/generate.py`. It sends the same prompt to an OpenAI image model and a Google image model concurrently so the owner can compare the results. This path is best when the member has the model-router installed.

### Path 2, built-in image tool

Use the host agent's own image generation tool and attach the selected identity photos as referenced image paths. This path is best when the member has no router.

The skill works with either path. Run `scripts/doctor.sh` to report which paths are available in the current environment.

## Authority and invariants

- Original photos outrank generated examples and prose.
- Never feed an AI-generated or AI-retouched image back in as an identity reference. Errors compound across generations.
- Likeness and anatomical plausibility outrank styling.
- Do not claim an exact match when facial features, proportions or other identity anchors visibly drift.
