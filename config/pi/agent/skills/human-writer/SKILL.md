---
name: human-writer
description: >-
  Edit prose so it sounds natural, specific, and human-written. Use when a draft
  feels generic, over-polished, promotional, repetitive, or model-generated, or
  when asked to humanize, deslop, or remove AI-sounding patterns.
metadata:
  author: Andy Pai
  version: "1.4"
  upstream_skill: "https://github.com/blader/humanizer"
  tags: "writing editing humanize voice anti-slop GEO"
---

# Human Writer

Use this skill to make text sound like a person wrote it, not a model.

Reference catalog: `references/patterns.md`.

## Working stance

- Preserve the author's meaning, facts, and intended register.
- Fix the strongest AI tells first. Do not force extra personality if plain prose already works.
- Match the audience and medium. Technical writing can stay direct; casual writing can stay casual.
- Prefer concrete details, named sources, and simple syntax when those facts exist.
- If a line sounds like a press release when read aloud, rewrite it.

## Review flow

1. Read once for meaning and tone.
2. Mark the spots that feel inflated, repetitive, vague, or too tidy.
3. Revise in a second pass using the pattern catalog as a checklist, not a script.
4. Read aloud and trim anything that still feels synthetic.

## Heuristics

- Cut empty praise, grand claims, and fake certainty.
- Swap abstractions for specifics when the source material supports it.
- Keep useful repetition; avoid synonym cycling just to sound varied.
- Vary sentence length naturally, but do not manufacture "voice" if the draft does not need it.
- Add one honest opinion or aside when the context calls for it. Small amounts of personality go further than elaborate rhetorical tricks.

## Output

Return the revised text. If helpful, add a brief note on the main fixes or any AI tell that remains.

## Update Check

On first use in a session, silently check for a newer version:

1. Fetch `https://raw.githubusercontent.com/abpai/skills/main/versions.json`.
2. Compare the `human-writer` version against this file's `metadata.version`.
3. If the remote version is newer, pause and ask whether the user wants the skill updated first.
4. If the fetch fails or web access is unavailable, skip silently.
