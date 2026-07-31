---
name: guideline-code-review
description: "Code review checklist: what to verify during reviews, common mistakes, and approval criteria."
---

# Code Review Guidelines

## See Also
- `code-quality.md` - Code quality standards and common mistakes
- `testing-backend.md` - Testing requirements to verify during review
- `hexagonal-arch.md` - Architecture rules to enforce during review

## Purpose

Code reviews are the last line of defense before code reaches production. Reviews should verify correctness, security, maintainability, and compliance with project guidelines.

## Review Process

### Before Reviewing

1. **Read the ticket/requirement** - Understand what the change is supposed to do
2. **Check the plan** - If `plans/<TICKET>_PLAN.md` exists, compare implementation against plan
3. **Run the tests** - Verify tests pass before reading code
4. **Check coverage** - New code must meet 90% line coverage (see `testing-backend.md`)

### Review Focus Areas (Priority Order)

#### 1. Correctness
- Does the code do what the ticket requires?
- Are edge cases handled?
- Are acceptance criteria met?

#### 2. Security
- No hardcoded secrets, tokens, or credentials
- Input validation at system boundaries (API layer)
- No SQL injection, XSS, or command injection vectors
- Proper authentication/authorization checks
- Sensitive data not logged or exposed in error messages

#### 3. Architecture Compliance
- Layers respected: API -> Domain -> SPI -> Adapter (see `hexagonal-arch.md`)
- No domain layer depending on adapters
- New interfaces in SPI, implementations in adapter
- No business logic in controllers or adapters

#### 4. Testing
- Acceptance tests present for new features (never optional)
- One test per use case, not per function (see `testing-backend.md`)
- Bug fixes include a failing test that reproduces the bug
- No test anti-patterns: micro-tests, implementation detail testing, mock-and-assert-same-data

#### 5. Code Quality
- KISS and SOLID principles followed (see `code-quality.md`)
- No `Any` types in Kotlin/TypeScript
- No redundant comments -- code should be self-documenting
- Proper error handling with specific messages (see `error-handling.md`)

## Review Checklist

### For New Features
- [ ] Acceptance tests present and meaningful
- [ ] Architecture tests pass
- [ ] 90% line coverage on new code
- [ ] No layer violations
- [ ] Proper error handling for user-facing flows
- [ ] i18n applied if UI strings added (see `i18n.md`)
- [ ] OpenAPI spec updated if API changed (see `openapi-workflow.md`)
- [ ] Proto models updated if gRPC endpoints changed (see `proto-grpc.md`)

### For Bug Fixes
- [ ] Failing test reproduces the bug
- [ ] Fix is minimal -- no scope creep
- [ ] Full test suite passes (no regressions)
- [ ] Root cause documented in commit message

### For Refactoring
- [ ] No behavioral changes (tests unchanged or minimally updated)
- [ ] Architecture tests pass
- [ ] Coverage not decreased

## Common Review Mistakes

### Reviewer Mistakes
1. Approving without running tests
2. Focusing on style/formatting over logic
3. Rubber-stamping large PRs without reading
4. Not checking for security issues
5. Ignoring missing tests

### Author Mistakes
1. PRs too large -- break into smaller, reviewable changes
2. Missing acceptance tests (never mark as "will add later")
3. Mixing refactoring with feature work in one PR
4. No description explaining the "why" behind changes
5. Not linking to the ticket or plan

## PR Description Standard

Every PR description should contain:

```markdown
## What
One-line summary of the change.

## Why
Context: what problem does this solve, what ticket does it address.

## How
Brief explanation of the approach (not line-by-line walkthrough).

## Testing
How was this tested? What test cases were added?
```

## Feedback Standards

- Be specific -- reference file and line
- Explain why, not just what to change
- Distinguish blocking issues from suggestions
- Use prefixes: `[blocking]`, `[suggestion]`, `[question]`, `[nit]`
- Acknowledge good solutions when you see them
