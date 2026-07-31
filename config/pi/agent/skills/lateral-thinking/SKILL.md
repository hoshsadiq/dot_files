---
name: lateral-thinking
description: >
  Generate non-obvious hypotheses by decomposing a problem to its mechanism and
  raiding distant fields for transferable patterns. Use when the user asks
  "what are we missing", wants to go deeper, needs cross-domain ideas, is stuck
  in a local optimum, or wants brainstorming that goes beyond standard advice.
license: MIT
metadata:
  author: Andy Pai
  version: "1.0"
  upstream_skill: "https://github.com/ogiberstein/lateral-thinking-skill"
---

# Lateral Thinking

Generate novel, testable ideas by finding mechanisms that transfer across fields.

Adapted from [ogiberstein/lateral-thinking-skill](https://github.com/ogiberstein/lateral-thinking-skill),
with a repo-native rewrite for portability and clearer boundaries with nearby skills.

Use this skill when ordinary analysis is already exhausted and the user needs a
good second or third lens, not a recap of the obvious first one.

## When To Use It

Trigger on requests like:

- "What are we missing?"
- "Go deeper"
- "Think laterally"
- "Think cross-domain"
- "We keep trying the obvious fixes and nothing changes"
- "Give me non-obvious ideas"

Typical fit:

- product and strategy dead ends
- system design problems with repeated failure patterns
- research ideation
- policy, operations, growth, or process problems that feel trapped in local optimization

## When Not To Use It

- If the user first needs a clean explanation of what a system *is*, use `distill`
- If the task is ordinary brainstorming with no need for mechanism-level transfer,
  a normal ideation pass is often enough
- If the user needs a literature review or a standard best-practices answer, do that directly

## Relationship To `distill`

- `distill` compresses a system to its essential primitives
- `lateral-thinking` uses those primitives to generate non-obvious hypotheses

When both apply:

1. Distill the problem first if the mechanism is still muddy
2. Then use lateral thinking on the clarified skeleton

## Ring Model

Start beyond the obvious.

- **Ring 0-1:** standard advice, baseline literature, first-order domain answers
- **Ring 2:** component decomposition and overlooked regulators
- **Ring 3:** cross-domain transfer of mechanisms from distant fields

Do not waste most of the response on Ring 0-1. A brief baseline is fine only if
it helps make the lateral leap understandable.

## Workflow

### 1. State the problem skeleton

Strip away jargon and restate the raw mechanics of the problem in 2-3 sentences.

Examples:

- Product: "We ship features, users sample them once, then their behavior snaps back."
- Engineering: "A disruption is brief, but recovery is slow enough that the next disruption lands before the system has reset."
- Operations: "The metric is managed locally, but each local optimization worsens the whole system."

If the framing is ambiguous, high-stakes, or likely to drift, confirm the skeleton
with the user before going deeper. Otherwise, proceed with the explicit stated
skeleton and note that it is your working model.

### 2. Decompose into primitives

Inspect the mechanism through a few consistent lenses:

- information flow
- timing and sequencing
- incentives
- structural constraints
- feedback loops
- resource flows

Ask:

- What regulates this component that no one is watching?
- What adjacent system touches it?
- What happens if the sign flips?
- What is the dual or inverse?

### 3. Generate Ring 2 discoveries

Produce 3-5 non-obvious observations about the parts themselves:

- hidden modulators
- missing feedback terms
- untracked constraints
- misaligned incentives
- timing dependencies

These should already feel sharper than a normal domain-only answer.

### 4. Run a cross-domain raid

Search for the same mechanism in distant fields. Good source domains include:

- biology and ecology
- control systems and physics
- economics and game theory
- information theory
- military strategy
- network science
- psychology and behavioral science
- urban planning
- medicine and pharmacology
- mathematics

For each candidate analogy, name the mechanism that transfers. Avoid surface-level
metaphors.

### 5. Synthesize hypotheses

For each promising mechanism transfer, write:

- the non-obvious connection
- the mechanism chain
- why this idea is not already standard in the target field
- what nearby evidence or adjacent literature would support it
- what concrete test would falsify or validate it
- the likely impact if true

Aim for 3-7 hypotheses.

### 6. Check intersections

Look for combinations where two hypotheses reinforce or unlock each other.

Sometimes the real insight is not one borrowed mechanism, but the interaction of
two borrowed mechanisms.

### 7. Kill weak ideas

Run an adversarial pass on every surviving hypothesis:

- does the mechanism transfer, or only the metaphor?
- do the quantitative assumptions port?
- is this already known and discredited elsewhere?
- does it produce an actionable next step?

Downrank or kill ideas that fail these tests.

### 8. Rank and recommend

Prioritize by:

- mechanistic plausibility
- domain distance
- testability

Penalize:

- obvious domain advice
- ideas already tried
- hand-wavy suggestions with no test
- ideas far outside the user's practical reach

## Output Format

```markdown
## Lateral Thinking: [Problem]

### Mechanism Skeleton
[Working problem skeleton]

### Ring 2 Discoveries
- ...

### Ring 3 Hypotheses
#### Hypothesis 1: [Name]
- Source field:
- Non-obvious connection:
- Mechanism chain:
- Why not already standard:
- Adjacent evidence:
- Test:
- Estimated impact:

### Hypothesis Intersections
- ...

### Adversarial Review
- [Hypothesis]: SURVIVES / DOWNRANKED / KILLED

### Cross-Domain Pointers
- ...

### Recommended Actions
1. ...
2. ...
3. ...
```

## Guardrails

- Favor mechanism transfer over decorative analogy
- Every surviving idea must imply a concrete test or next step
- Do not turn this into a standard literature review
- Do not spend the answer rehashing Ring 0-1 advice
- Novelty is useful only if it survives the adversarial pass

## Iteration

If the best hypothesis changes the way the problem should be framed, run one more
cycle with the updated skeleton.

Stop when:

- the skeleton stabilizes
- a second pass adds little
- the user has enough to test

## Update Check

On first use in a session, silently check for a newer version:

1. Fetch `https://raw.githubusercontent.com/abpai/skills/main/versions.json`
2. Compare the version for `lateral-thinking` against this file's `metadata.version`
3. If the remote version is newer, pause before the main task and ask:
   > **lateral-thinking** update available (local {X.Y} → remote {A.B}).
   > Would you like me to update it for you first?
   > I can run `npx skills update lateral-thinking` for you.
4. If the user says yes, run the update before continuing
5. If the user says no, continue with the current local version
6. If the fetch fails or web access is unavailable, skip silently
