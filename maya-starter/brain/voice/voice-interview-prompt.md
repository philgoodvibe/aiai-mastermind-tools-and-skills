# Voice Interview Prompt

This is the prompt that builds your voice profile. Paste the block below into the Claude Code panel in VS Code when you have 15 to 20 minutes. MAYA asks you 10 questions, one at a time, and then writes `brain/voice/voice-profile.md` from your answers.

Answer by voice for the best result. Record yourself on your phone and paste the transcript, or dictate your answer straight into the panel. Voice carries your real phrasing better than typing does. If you would rather type, type loose and unedited. Do not clean it up. The messy, real version is exactly what MAYA needs.

---

```
You are going to interview me to build my voice profile, then write it to
brain/voice/voice-profile.md. This file is how I actually talk, and you will
gate every future caption against it, so get my real voice, not a polished
version of it.

Rules for the interview:

- Ask me ONE question at a time. Wait for my answer before the next question.
- After each answer, give a short, warm follow-up that digs for a specific:
  a moment, a phrase I used, a feeling, an example. Make me say more before
  you move on. Two or three follow-ups per question is fine if I am giving
  you good material.
- Preserve my exact phrasing. Capture the words and phrases I actually use.
- Do NOT polish my voice. Do NOT make me sound more formal, more corporate,
  or more "professional" than I am.
- Do NOT invent verbal tics, catchphrases, or mannerisms you did not hear me
  use. If I never said it, it does not go in the profile.
- I may answer by voice (pasted transcript or dictation) or by typing loose
  and unedited. Either way, work from my real words.

Ask me these 10 questions, in this order, one at a time, with warm follow-ups:

Origin and Why
1. What's your origin story, how did you end up in insurance?
2. What moment made you realize this career was more than just a job?

Expertise and Proof
3. What's one thing you wish every client understood about insurance?
4. Tell me about a time you saved a client from a disaster they didn't see
   coming.
5. What mistake do you see people make over and over with their coverage?

Connection and Heart
6. Why should someone pick you over another agent?
7. What's a moment with a client that reminded you why you do this?
8. If you could sit down with every person in your community for five
   minutes, what would you tell them?

Daily Life and Human Side
9. What does a typical day look like for you outside of insurance?
10. What are you passionate about that has nothing to do with work?

When the interview is done, write brain/voice/voice-profile.md following the
structure in brain/voice/voice-profile-template.md. Fill every section from my
answers, quoting my real phrasing where you can. Include the Tuning Fork
Sentence (one 15 to 30 word sentence in my voice) and the Voice Matching
Checklist (the per-owner checklist you will gate every caption against).
Then show me the finished profile and ask me to confirm it sounds like me
before you treat it as final.

Start with question 1 now.
```

---

After MAYA writes the profile, read it out loud. If a line does not sound like you, tell MAYA exactly what is off ("I would never say that," "too stiff," "that's not my word"). MAYA updates `voice-profile.md` on the spot. The profile gets sharper every time you correct a draft, so it is never truly finished, just good enough to start.
