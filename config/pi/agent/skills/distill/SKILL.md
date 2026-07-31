---
name: distill
description: >
  Iteratively decompose complex systems into their essential primitives — the minimal
  set of abstractions that capture the full essence. Use this skill whenever the user
  wants to understand the "real building blocks" of something: a codebase, a research
  paper, a collection of documents, a transcript, an architecture, or any complex
  system. Trigger on phrases like "distill this", "what are the primitives",
  "what's the essence of", "boil this down", "simplify this to its core",
  "extract the key abstractions", "what are the real building blocks",
  "give me the Karpathy version", "minimal representation", or any request
  to compress a complex input into its fundamental components. Also trigger when
  the user asks to "understand" or "analyze" a large codebase or document set
  and seems to want a compressed mental model rather than a line-by-line walkthrough.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - AskUserQuestion
  - Agent
license: MIT
metadata:
  author: Andy Pai
  version: "1.0"
---

# Distill

A skill for iteratively compressing complex systems down to their essential primitives —
the minimal set of abstractions that captures the full behavioral essence while
discarding accidental complexity.

Use `distill` when the user needs a cleaner mental model of something complicated.
If the real need is to generate non-obvious hypotheses, cross-domain analogies, or
mechanism transfers, prefer `lateral-thinking` instead.

Think of it like Andrej Karpathy reducing an automated research system to three files
(`train.py`, `prepare.py`, `program.md`). The goal is not summarization — it's
**re-expression in minimal form**.

## Core Concepts

**Primitives**: The irreducible building blocks that can't be decomposed further
without losing essential behavior. A good primitive set is:
- **Complete** — you can reconstruct the full system's behavior from just these pieces
- **Orthogonal** — each primitive captures something the others don't
- **Minimal** — removing any one primitive loses something essential

**Distillation vs. Summarization**: Summarization preserves information at lower
fidelity. Distillation re-expresses the essence in a new, cleaner form. The output
of distillation is often *more useful* than the original because it strips away
accidental complexity.

**Accidental vs. Essential Complexity** (per Fred Brooks): Essential complexity is
inherent to the problem. Accidental complexity comes from the implementation.
Distillation separates them.

## Workflow

The distillation process has two phases: **Orient** and **Compress**. These iterate
until the user is satisfied with the decomposition.

### Phase 1: Orient

Before proposing any decomposition, understand what the user cares about. This
determines what counts as "essential."

Ask clarifying questions like:
- What are you trying to *do* with this understanding? (Build on top of it?
  Rewrite it? Teach it? Make decisions about it?)
- What layer are you most interested in? (Business logic? Data flow? API surface?
  Conceptual model?)
- Is there a part you already understand well vs. a part that's opaque?
- What's your current mental model, even if rough?

Keep this phase lightweight — 2-4 questions max. The goal is to calibrate, not
to conduct a full interview. If the user's intent is obvious from context, skip
straight to Phase 2.

### Phase 2: Compress

This is the iterative core. Each turn follows this pattern:

#### Step 1: Propose Primitives

Present a candidate decomposition. Format depends on context (see Output Formats below),
but always include:

1. **The primitive set** — named, with a one-sentence description of each
2. **Proposed granularity** — how many primitives, and why this number
3. **What was discarded** — what you treated as accidental complexity and removed
4. **Confidence flags** — where you're least sure about the decomposition

Example of a good proposal:

```
## Proposed Primitives (4)

1. **Ingestion** — accepts raw input (PDF, URL, repo path) and normalizes to
   a common internal representation
2. **Chunking** — splits normalized input into semantically meaningful units
3. **Extraction** — pulls structured claims/facts/abstractions from each chunk
4. **Synthesis** — combines extracted pieces into the final compressed output

Discarded as accidental: file format handling, caching, logging, CLI argument parsing

Uncertain about: whether Chunking and Extraction are truly separate primitives
or two aspects of the same operation. Interested in your read.
```

#### Step 2: Invite Pushback

Explicitly ask the user to challenge the decomposition:
- "Does this match your intuition? What feels wrong?"
- "Are any of these actually the same primitive in disguise?"
- "Am I missing a primitive, or is one of these not truly essential?"

#### Step 3: Refine

Based on feedback, propose a revised decomposition. Show what changed and why.
Repeat until the user says it feels right.

### Convergence Signals

You're done when:
- The user confirms the primitive set matches their intuition
- Each primitive feels irreducible — you can't merge or remove any
- The user can explain the system to someone using only these primitives
- (For code) you could sketch a minimal implementation from just the primitive set

## Output Formats

Choose the output format based on what the user needs. When in doubt, ask.

### Conceptual Map (default for non-code inputs)
A structured document listing the primitives, their relationships, and how they
compose to produce the full system's behavior.

```markdown
# [System Name] — Distilled

## Primitives
1. **Name** — description
2. **Name** — description

## Relationships
- Primitive A feeds into Primitive B via [mechanism]
- Primitives C and D are independent but both required for [outcome]

## Reconstruction
Given these primitives, here's how the full system works: [narrative]

## What Was Discarded
- [thing] — accidental complexity because [reason]
```

### Minimal Implementation (default for codebases)
A set of files (like Karpathy's 3 files) that capture the essential behavior.
These should be:
- Actually runnable (or close to it)
- Named to reflect the primitives they embody
- Stripped of all accidental complexity
- Commented to explain what each piece maps to in the original

### Behavioral Spec (when user wants a SKILL.md or similar)
A specification that captures what the system *does* without prescribing *how*.
Useful when the distillation will be used to guide an agent or a rewrite.

### Hybrid
For complex systems, combine formats: a conceptual map plus a minimal implementation,
or a behavioral spec with a reference implementation.

## Input-Specific Strategies

### Codebases
1. Start with the entry points — what gets called first?
2. Trace the critical path for the most common operation
3. Identify data structures that everything revolves around
4. Look for the "God objects" — they often contain multiple primitives fused together
5. Separate domain logic from infrastructure (HTTP, DB, auth, logging)

For multi-repo / polyglot codebases: look for the *conceptual* primitives that
cross language boundaries, not the file-level structure.

### Research Papers / Technical Documents
1. What's the core claim or contribution?
2. What's the minimal setup needed to understand that claim?
3. What's the method, stripped of notation and formalism?
4. What prior work is essential context vs. just literature review?

### Transcripts / Conversations
1. What decisions were made?
2. What were the real alternatives considered (not just mentioned)?
3. What constraints shaped the decisions?
4. What's the underlying model/framework the participants are reasoning from?

### Blog Posts / Articles
1. What's the one idea that, if you understood it, you'd understand the whole piece?
2. What evidence actually supports it vs. is just color?
3. Is there an implicit framework the author is using?

## Anti-Patterns

Avoid these common failure modes:

- **Summarizing instead of distilling** — if your output is just a shorter version
  of the input with the same structure, you're summarizing, not distilling
- **Too many primitives** — if you have more than 7, you probably haven't compressed
  enough. The sweet spot is usually 3-5.
- **Confusing implementation with essence** — "uses PostgreSQL" is implementation;
  "needs durable ordered storage" is essence
- **Premature convergence** — don't lock in after one pass. The first decomposition
  is usually wrong in interesting ways.
- **Symmetry bias** — don't force primitives to be at the same level of abstraction.
  Sometimes one primitive is genuinely bigger than the others.

## Session Management

Distillation often spans multiple turns. Keep a running state:

- Current primitive set (numbered, for easy reference)
- Open questions
- What's been discarded and why
- Iteration count

If the session gets long, offer to write the current state to a file so the user
can resume later or hand it to another agent session.

## Update Check

On first use in a session, silently check for a newer version:

1. Fetch `https://raw.githubusercontent.com/abpai/skills/main/versions.json`.
2. Compare the version for `distill` against this file's `metadata.version`.
3. If the remote version is newer, pause before the main task and ask:
   > **distill** update available (local {X.Y} → remote {A.B}).
   > Would you like me to update it for you first?
   > I can run `npx skills update distill` for you.
4. If the user says yes, run the update before continuing.
5. If the user says no, continue with the current local version.
6. If the fetch fails or web access is unavailable, skip silently.
