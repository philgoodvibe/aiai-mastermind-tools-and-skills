# Identity Profile Template

> Describe only what is actually visible across the original reference photos. Write factually and respectfully. Avoid flattering, euphemistic or aspirational wording, because vague descriptions produce generic faces. Do not infer sensitive traits, health, identity, personality or ability from appearance. Use they/them pronouns for the skill owner.
>
> This file is intentionally uncustomized while any double-brace token remains, including this setup marker: `{{PLACEHOLDER}}`. <!-- Remove this marker only after every field below has been completed from original photos. Example: remove the marker after the profile and photo slots have been checked. -->

## Identity anchors

- **Head and face shape:** {{HEAD_AND_FACE_SHAPE}} <!-- Describe visible overall head outline, face length, jaw and chin without value judgments. Example: "Medium-length oval outline with a softly angled jaw and rounded chin." -->
- **Cheeks:** {{CHEEKS}} <!-- Describe cheek fullness, cheekbone visibility and how these change with expression. Example: "Moderate cheek fullness, with cheekbones becoming clearer in a broad smile." -->
- **Eyes:** {{EYES}} <!-- Describe visible shape, spacing, lid form and typical openness, not inferred ethnicity or emotion. Example: "Slightly rounded eyes with even spacing and mildly hooded upper lids." -->
- **Brows:** {{BROWS}} <!-- Describe visible thickness, shape, spacing and direction. Example: "Medium-thick brows with a mostly straight line and a gentle outer arch." -->
- **Nose:** {{NOSE}} <!-- Describe bridge, width, tip and nostril shape as observed from more than one photo. Example: "Straight bridge, moderate width and a softly rounded tip." -->
- **Mouth and lips:** {{MOUTH_AND_LIPS}} <!-- Describe mouth width, lip shape, relative fullness and resting line. Example: "Medium-width mouth, defined upper bow and a fuller lower lip." -->
- **Skin:** {{SKIN}} <!-- Describe visible tone range, undertone if clear, texture and stable marks without smoothing or diagnosis. Example: "Medium tone with a neutral-warm cast, natural texture and a small visible mark near one cheek." -->
- **Facial hair or absence of it:** {{FACIAL_HAIR}} <!-- State only the stable visible pattern, including an observed absence. Example: "No visible facial hair in the primary references." -->
- **Hair:** {{HAIR}} <!-- Describe current length, texture, density, hairline, part and usual shape only when visible. Example: "Short, dense, loosely wavy hair with a visible natural hairline and side part." -->
- **Build and proportions:** {{BUILD_AND_PROPORTIONS}} <!-- Describe relative shoulder, torso and limb proportions from suitable photos without labels or judgments. Example: "Shoulders slightly wider than the hips, with balanced torso-to-leg proportions." -->
- **Eyewear:** {{EYEWEAR}} <!-- Describe usual eyewear, or its observed absence, and note whether a support image controls frame detail. Example: "Usually wears thin, rounded rectangular frames; use the labeled support photo for frame detail only." -->
- **Demeanor:** {{DEMEANOR}} <!-- Describe repeatable visible presentation, pose and expression rather than inferred personality. Example: "Relaxed upright posture, direct gaze and restrained expressions in most references." -->

## Reference authority

The five primary slots are evidence sources, not interchangeable decoration. Record what the installed photo in each slot can authoritatively establish.

- **Slot A, primary-face:** {{SLOT_A_AUTHORITY}} <!-- State the reliable face details visible in this clear close view. Example: "Primary authority for eye spacing, nose shape, mouth shape, jaw and skin texture." -->
- **Slot B, upper-body:** {{SLOT_B_AUTHORITY}} <!-- State the reliable combined face, posture and build evidence in this view. Example: "Primary overall authority for likeness, usual posture, shoulder line and head-to-torso scale." -->
- **Slot C, proportions:** {{SLOT_C_AUTHORITY}} <!-- State the body proportion and stance evidence visible without guessing hidden anatomy. Example: "Authority for torso-to-leg balance, shoulder-to-hip relationship and natural standing stance." -->
- **Slot D, expression-open-smile:** {{SLOT_D_AUTHORITY}} <!-- State the reliable teeth, mouth and cheek behavior shown in a broad smile. Example: "Authority for visible teeth, smile width, lip movement and cheek lift during an open smile." -->
- **Slot E, secondary-face:** {{SLOT_E_AUTHORITY}} <!-- State which stable facial details this second angle confirms. Example: "Confirms jaw contour, brow shape, nose projection and hairline from a slight turn." -->

Default authority order: B, A, C, D, E. Original photos always outrank generated images and prose.

## Support-only assets

- **Installed support assets and narrow purpose:** {{SUPPORT_ONLY_ASSETS}} <!-- List each optional support filename and exactly one permitted use, or write "None installed." Example: "eyewear-detail.jpeg, frame color and hinge shape only." -->

Support-only assets must never control facial geometry, feature spacing, head shape or general likeness.

## Reusable prompt block

Copy this compact block after the requested concept and style. Replace all remaining tokens during setup.

```text
IDENTITY PRIORITY: Preserve the identity of the person in the original reference photos above all styling. They have {{HEAD_AND_FACE_SHAPE}}, {{CHEEKS}}, {{EYES}}, {{BROWS}}, {{NOSE}}, {{MOUTH_AND_LIPS}}, {{SKIN}}, {{FACIAL_HAIR}}, {{HAIR}}, and {{BUILD_AND_PROPORTIONS}}. Eyewear: {{EYEWEAR}}. Their visible presentation is {{DEMEANOR}}. Expression: {{EXPRESSION_CLAUSE}}. Use a natural eye-level portrait perspective unless the scene request specifies another view. Keep facial geometry, apparent age, body proportions, skin texture and the profile's described hair consistent. Do not beautify, genericize, plastic-smooth, add or remove hair, or change stable identity traits. Apply style only after identity is locked.
```

## Expression clauses

- **Neutral:** {{EXPRESSION_NEUTRAL}} <!-- Describe the owner's observed neutral mouth, eyes and facial tension. Example: "Neutral resting mouth, naturally open eyes and relaxed cheeks." -->
- **Gentle closed-mouth smile:** {{EXPRESSION_GENTLE_CLOSED_MOUTH_SMILE}} <!-- Describe the observed subtle smile without inventing dimples or changing eye shape. Example: "Small closed-mouth smile with mild cheek lift and relaxed eyes." -->
- **Broad open smile:** {{EXPRESSION_BROAD_OPEN_SMILE}} <!-- Describe observed smile width, visible teeth, cheek lift and eye response from slot D. Example: "Broad open smile with the observed visible teeth pattern, raised cheeks and natural eye narrowing." -->

## Camera and anatomy guidance

- Default to an eye-level camera and natural portrait perspective.
- Avoid close, extreme wide-angle perspective that enlarges central features and distorts head shape.
- Keep the face large enough to compare with references when likeness is important.
- Preserve the observed head-to-body scale and build from slots B and C.
- When arms or hands are prominent, require natural shoulder and elbow articulation, plausible limb lengths, two hands where expected and five anatomically arranged digits per visible hand unless the concept explicitly requires otherwise.
- Keep occlusion, foreshortening, contact and weight-bearing physically plausible.

## Pre-delivery QA checklist

- [ ] The result clearly matches the same person across head shape, feature spacing, eyes, brows, nose, mouth and jaw.
- [ ] Apparent age has not drifted.
- [ ] Skin retains natural texture and has not been plastic-smoothed.
- [ ] Hair, facial hair and eyewear match the profile and request.
- [ ] The requested expression follows the relevant expression clause.
- [ ] Build, body proportions and head-to-body scale remain consistent with slots B and C.
- [ ] Camera perspective is natural or matches the owner's explicit request.
- [ ] Hands, limbs, joints, teeth and visible anatomy are plausible.
- [ ] Styling has not overridden identity.
- [ ] No generated or AI-retouched image was used as an identity reference.
- [ ] Any support-only image was used only for its labeled narrow purpose.
- [ ] If any identity anchor visibly drifted, one focused regeneration corrected only the failed traits.
