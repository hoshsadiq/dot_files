---
name: deslop
description: >-
  Edit prose so it sounds natural, specific, and human-written. Use when a draft
  feels generic, over-polished, promotional, repetitive, or model-generated, or
  when asked to humanize, deslop, or remove AI-sounding patterns. Also trigger
  when asked to review, clean up, or tighten writing that reads like it came
  from a language model, even if the user doesn't use the word "slop", including
  blog posts, documentation, marketing copy, emails, bios, and any other prose.
metadata:
  author: Hosh
  version: "1.0"
  tags: "writing editing humanize voice anti-slop deslop prose"
---

# Deslop

Make text sound like a person wrote it, not a model.

Pattern catalog: `references/patterns.md`. Read it on first use as a checklist reference.

## Stance

- Preserve the author's meaning, facts, and intended register. Never invent facts or change what the text claims.
- Fix the strongest AI tells first. Don't force personality onto prose that works fine as plain writing.
- Match the audience and medium. A technical doc stays direct. A blog post can be looser. A bio stays tight.
- Prefer concrete details, named sources, and simple syntax when the source material has them.
- If a line sounds like a press release when read aloud, rewrite it.
- Restructure freely when it helps: combine bullet lists into prose, merge redundant paragraphs, reorder for flow. The restructured version must say the same things.

## Process

1. Read the full text for meaning, tone, and audience.
2. Identify the worst offenders: inflated language, filler, robotic rhythm, promotional drift, em dash clusters, "not just X, it's Y" constructions, synonym cycling, rule-of-three abuse.
3. Rewrite in one pass, using `references/patterns.md` as a checklist, not a script. Not every pattern applies to every text.
4. Read the result aloud. Cut anything that still sounds like a press release or a chatbot.

## What to fix

These are the most common tells, roughly ordered by how much damage they do:

**Significance inflation.** AI turns ordinary facts into pivotal moments. "Marking a turning point in the evolution of..." Just state what happened.

**Promotional drift.** Brochure language: nestled, vibrant, boasts, breathtaking, rich cultural heritage, commitment to excellence. Replace with plain description.

**Filler and hedging.** "It's important to note that," "has the ability to," "it could potentially possibly be argued." Cut or compress.

**Em dash overuse.** Models reach for em dashes far more than humans do. Most can become commas, periods, or parentheses. Or the aside can just be cut.

**Contrastive negation.** "It's not just X, it's Y" and "not only X but Y." These are fine occasionally, but AI uses them as a default intensifier. Flatten unless there's a real distinction being made.

**Synonym cycling.** The protagonist, the main character, the central figure, the hero. Just pick one and reuse it. Repetition is natural; forced variation is not.

**Rule of three.** Three-item lists aren't wrong, but when every sentence has exactly three items, it reads as generated.

**Participle padding.** Chains of -ing words that add no information: "highlighting the importance of... underscoring the significance of... reflecting the deep connection to..."

**Staccato rhythm.** Too many short declarative sentences in a row. Or the opposite: everything uniformly long and polished. Real writing has uneven rhythm.

**Grand conclusions.** "The future looks bright." "This is just the beginning." "Exciting times lie ahead." Replace with something concrete or cut entirely.

**Copula avoidance.** "Serves as," "stands as," "functions as." Just say "is."

**Communication artifacts.** "Great question!" "I hope this helps!" "Let me know if you'd like..." Residue from chat that leaked into the draft.

## What to preserve

- Technical accuracy and domain-specific terminology.
- The author's actual voice, if one exists in the draft. Don't replace one artificial voice with another.
- Useful structure. Not every list needs to become prose, and not every heading needs to go.
- Intentional repetition that serves emphasis or clarity.

## Output

Return the revised text. Format should match the input: if they gave you markdown, return markdown. If plain text, plain text.

After the revised text, add a short note on what you changed and why. A few sentences, not a changelog.

If AI tells remain that you couldn't fix without changing meaning (e.g., the content itself is vague), flag them.
