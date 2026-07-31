---
name: dead-code-eliminator
description: >
  Audit a codebase for dead code first: unreachable functions, unused
  imports, orphaned classes, unreachable branches, stale feature flags,
  and symbols that only survive through dynamic dispatch or external
  consumers. Use when the user asks to find dead code, unused exports,
  orphaned functions, or wants a safe removal plan after an audit.
license: MIT
metadata:
  author: Andy Pai
  version: "1.2"
  tags: "dead-code cleanup refactor audit unused imports"
---

# Dead Code Eliminator

Use this skill when the user wants a dead-code audit, not a broad refactor. The default outcome is a reachability report and a removal order, with code changes only after the audit is clear.

## Main Workflow

1. Find the project entry points: executables, CLI bins, routes, jobs, exports, package indexes, and framework lifecycle hooks.
1. Trace the live set from those roots through imports, calls, instantiations, and other statically provable edges.
1. Mark anything unresolved, conditional, or externally consumable instead of guessing reachability.
1. Separate test-only reachability from production reachability.
1. Report dead code candidates, confidence level, and any correctness or soundness concerns in the live code.
1. If the user asks for removal, delete in dependency-safe order after the audit is complete.

## Safety Rules

- Do not guess through reflection, `eval`, string dispatch, or other dynamic lookup paths.
- Treat feature-flagged or environment-conditional code as conditionally reachable and name the condition.
- Treat symbols that may be consumed outside the repository as `unused export (external consumers possible)`, not as dead code.
- Do not collapse low-confidence items into the dead list without calling out the uncertainty.
- Stop and ask for a narrower scope if the codebase is too large to trace confidently.

## Output Rules

- Always start with the live-entry-point and reachability picture before listing dead code.
- Keep the main report focused on the audit result, not on style commentary.
- Use `references/report-shape.md` for the exact report sections, item formatting, and removal-order template.
- Include correctness and algorithmic-soundness suggestions only for live code.

## Decision Heuristics

- Prefer conservative reachability over false positives.
- Prefer a smaller proven live set over speculative reachability.
- Prefer explicit confidence labels over silent omissions.
- Prefer audit-first output over code edits unless the user explicitly asks to remove code.

## Update Check

On first use in a session, silently check for a newer version:

1. Fetch `https://raw.githubusercontent.com/abpai/skills/main/versions.json`.
2. Compare the version for `dead-code-eliminator` against this file's `metadata.version`.
3. If the remote version is newer, pause before the main task and ask:
   > **dead-code-eliminator** update available (local {X.Y} → remote {A.B}).
   > Would you like me to update it for you first?
   > I can run `npx skills update dead-code-eliminator` for you.
4. If the user says yes, run the update before continuing.
5. If the user says no, continue with the current local version.
6. If the fetch fails or web access is unavailable, skip silently.
