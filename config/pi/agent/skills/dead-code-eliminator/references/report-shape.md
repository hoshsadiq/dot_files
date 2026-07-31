# Dead Code Report Shape

Use this as the template for the audit output. Keep the report concise in the main response, but preserve the same sections and confidence language.

## Suggested Order

1. Entry points and live-set summary.
1. Dead code candidates by category.
1. Test-only symbols.
1. Suggestions for live code correctness or soundness.
1. Safe removal order.

## Dead Code Item Format

Group items by category, then order each category by file path.

```text
[CATEGORY] src/utils/helpers.ts:42
  Symbol: formatLegacyDate()
  Purpose: ISO-8601 formatter for v1 API responses
  Confidence: HIGH
```

Keep the category label explicit when the item is only conditionally reachable or when external consumers may still depend on it.

## Confidence Rules

- `HIGH`: provably unreachable from the traced live set.
- `LOW`: heuristic result, dynamic dispatch may still reach it, or the project shape prevents a fully provable conclusion.
- Always surface the reason for uncertainty.

## Safe Removal Order

Use a dependency-safe sequence:

1. Unused imports.
1. Leaf functions and methods.
1. Mid-graph call sites once their callees are gone.
1. Orphaned classes after their methods are removed.
1. Stale feature-flag branches.
1. Dead files once all contained symbols are gone.

## Minimal Report Skeleton

```text
1. Live entry points
2. Dead code report
3. Test-only symbols
4. Suggestions
5. Safe removal order
```
