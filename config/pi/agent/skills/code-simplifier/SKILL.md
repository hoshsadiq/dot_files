---
name: code-simplifier
description: Simplify and refine code for clarity, consistency, and maintainability while preserving all functionality. Focuses on recently modified code unless instructed otherwise.
metadata:
  version: "2.0"
---

# Code Simplifier

Review changed code for reuse, quality, and efficiency, then simplify and fix any issues found.

## Core Rules

1. Preserve functionality exactly.
1. Keep public behavior, outputs, side effects, and interfaces unchanged.
1. Follow project-specific coding standards and patterns.
1. Prefer clarity over compactness.
1. Avoid clever rewrites that reduce debuggability.

## Scope

- Default to the current task's changed files.
- Focus on code the user just changed or that you changed in this conversation.
- Keep fixes behavior-preserving unless the user explicitly asked for broader refactors.

## Phase 1: Identify Changes

1. Run `git diff`.
1. If there are staged changes, prefer `git diff HEAD` so staged and unstaged edits are both visible.
1. If there are no git changes, inspect the most recently modified files relevant to the task.

## Phase 2: Run Three Reviews In Parallel

If subagents are available, launch all three review agents concurrently in a single round and pass each agent the full diff.

If subagents are not available, perform the same three review passes yourself.

### Review 1: Code Reuse

Check whether the change reimplements logic that already exists.

- Search for existing helpers, utilities, and shared abstractions that could replace new code.
- Look in utility directories, shared modules, and files adjacent to the changed code.
- Flag new functions that duplicate existing behavior.
- Flag inline logic that should use an existing utility instead of hand-rolled code.
- Common duplication targets include string manipulation, path handling, env detection, parsing helpers, and type guards.

### Review 2: Code Quality

Check for structural and maintainability issues.

- Redundant state: duplicated state, cached values that could be derived, effects that could be direct calls.
- Parameter sprawl: new parameters added where restructuring or generalization would be cleaner.
- Copy-paste variation: near-duplicate blocks that should share an abstraction.
- Leaky abstractions: exposing internal details or breaking module boundaries.
- Stringly-typed code: raw strings where constants, unions, or existing types should be used.
- Unnecessary nesting and branching complexity.
- Unclear identifiers that obscure intent.
- Dense logic that should be split into coherent, single-purpose helpers.
- Fragile one-liners that should be explicit, readable control flow.
- Unnecessary comments: remove comments that only restate what the code does; keep only non-obvious why.

### Review 3: Efficiency

Check for unnecessary work and avoidable overhead.

- Unnecessary work: redundant computation, repeated file reads, duplicate API calls, N+1 patterns.
- Missed concurrency: independent work done sequentially when it could run in parallel.
- Hot-path bloat: new blocking work in startup, render, request, or polling paths.
- Recurring no-op updates: state or store writes that fire even when nothing changed.
- Unnecessary existence checks: prefer operating directly and handling errors over TOCTOU pre-checks.
- Memory issues: unbounded collections, missing cleanup, leaked listeners or subscriptions.
- Overly broad operations: reading or loading more data than needed.

## Phase 3: Simplify and Fix

1. Aggregate the findings from all three review passes.
1. Fix each worthwhile issue directly.
1. If a finding is a false positive or not worth changing, skip it without debate.
1. Re-check the edited code for correctness and local consistency.
1. Run available lint, test, or targeted validation when practical.

## Boundaries

Do not:

- Change business logic or edge-case behavior.
- Alter API contracts, data formats, or error semantics unless requested.
- Expand scope beyond recently touched code unless explicitly requested.
- Over-normalize style at the expense of local codebase conventions.

## Decision Heuristics

- If two versions are equivalent, choose the one a new teammate can understand fastest.
- Keep useful abstractions; remove only those that add indirection without value.
- Prefer straightforward flow over reduced line count.
- Stop when readability gains flatten out.

## Output

When finished, briefly summarize:

- what you fixed
- what you intentionally skipped
- whether the reviewed code was already clean
