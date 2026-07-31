---
name: guideline-tdd-workflow
description: "TDD workflow: Red-Green-Refactor phases, spec file conventions, feature and bugfix workflows."
---

# TDD Workflow Guidelines

> Source: projectcore/CODEGEN-GUIDELINE.md

## See Also
- `hexagonal-arch.md` - Architecture rules
- `testing-backend.md` - Backend testing patterns

## Spec File Naming Convention

- All specs must go into `.kiro/specs/` directory (NOT `/specs/`)
- Naming format: `.kiro/specs/<JIRA_TICKET>_<short-kebab-case-description>/`
- Each spec has three files: `requirements.md`, `design.md`, `tasks.md`
- **Important**: If no Jira ticket number is provided, you MUST ask for it before creating any spec file
- Never invent or generate Jira ticket numbers

## Atomic Commits

Each commit should focus on a single logical change.

### For New Features:
Commit at phases that result in meaningful changes:
- `TDD Phase 1 (RED): Create acceptance tests`
- `TDD Phase 2 (GREEN): Design classes/interfaces`
- `TDD Phase 4 (GREEN): Implement minimal code`
- `TDD Phase 5 (REFACTOR): Refactor code`

Phases 3 and 6 are verification steps—only commit if they result in actual code changes.

### For Feature Enhancements:
Commit at phases that result in meaningful changes:
- `Enhancement Phase 2 (RED): Update existing tests` (if tests were modified)
- `Enhancement Phase 3 (GREEN): Implement changes`
- `Enhancement Phase 4 (REFACTOR): Refactor code`

Phases 1 and 5 are verification steps—only commit if they result in actual code changes.

## TDD Workflow

### For New Features (6 Phases)

#### Phase 1: RED - Create Acceptance Tests
1. Create acceptance test(s) that relate to a use case
2. Acceptance tests should span the full application flow (e.g., from API layer through persistence layer)
3. Tests should verify the complete behavior including side effects with minimal mocking
4. Each acceptance test represents a single use case and should be readable to convey expectations
5. Solution will NOT build at this point - this is expected
6. Place tests in the appropriate test directory for your project structure

#### Phase 2: GREEN - Run Architecture Tests
1. Suggest all classes/interfaces that should be created
2. Organize them by layer according to your project's architecture
3. Get user review and approval
4. Ensure solution builds (even if tests fail)
5. Verify no architecture violations using your project's architecture tests

#### Phase 3: RED - Ensure Solution builds and newly created tests fails
1. Newly created acceptance tests should fail (this is expected)

#### Phase 4: GREEN - Minimal Implementation
1. Fill in minimal code to fulfill the acceptance tests
2. Focus on making tests pass, not on perfection
3. Run all tests to ensure they pass

#### Phase 5: REFACTOR - Code Review & Refactoring
1. Have user review the generated code
2. Suggest refactoring opportunities
3. Improve code quality, readability, and maintainability
4. Consider KISS, SOLID, design patterns, and best practices

#### Phase 6: VERIFY - Run All Tests and verify Test Coverage
1. Run all existing tests to ensure nothing breaks from refactoring
2. Newly generated classes/models should have **≥ 90% line coverage**
3. Use Kover reports to verify coverage
4. Add additional unit tests for API layer if needed (narrow tests verifying request → api port mapping)
5. SPI layer coverage is included in acceptance tests, no separate SPI unit tests needed

### For Feature Enhancements (Simplified Workflow)

When enhancing existing features (modifying existing files/classes):

#### Phase 1: ASSESS - Review Existing Tests
1. Identify existing acceptance tests or integration tests that cover the feature
2. Determine if existing tests need updates to cover new behavior
3. **Only create new acceptance tests if:**
   - The enhancement adds a completely new use case
   - Existing tests don't cover the modified behavior at all
4. **Reuse and enhance existing tests** when possible

#### Phase 2: RED - Update Tests (if needed)
1. Update existing acceptance/integration tests to reflect new behavior
2. Ensure tests fail with the expected new behavior (RED state)
3. **Skip architecture tests** unless adding new files/classes

#### Phase 3: GREEN - Implement Changes
1. Modify existing code to fulfill the updated test expectations
2. Focus on minimal changes to make tests pass
3. Run all tests to ensure they pass

#### Phase 4: REFACTOR - Code Review & Refactoring
1. Have user review the changes
2. Suggest refactoring opportunities
3. Improve code quality while maintaining test coverage

#### Phase 5: VERIFY - Run All Tests and verify Test Coverage
1. Run all existing tests to ensure nothing breaks
2. Verify coverage remains **≥ 90%** for modified code
3. Add targeted unit tests only if coverage drops below threshold

### For Bug Fixes (Test-First Approach)

When fixing bugs, always replicate the bug in tests before fixing:

#### Phase 1: ASSESS - Analyze the Bug
1. Understand the bug behavior and expected correct behavior
2. Identify which component/layer is affected
3. Locate existing tests that should have caught this bug

#### Phase 2: RED - Replicate Bug in Tests
1. **If existing tests cover the area:**
   - Modify existing acceptance/integration tests to include the failing case
   - Add a test case that demonstrates the bug
   - Ensure the test fails (RED state) - this confirms the bug exists
   
2. **If no existing tests cover the area:**
   - Create a new acceptance test that replicates the bug scenario
   - Test should span the full flow where the bug occurs
   - Ensure the test fails (RED state) - this confirms the bug exists

3. **Do NOT skip this phase** - A failing test is proof the bug exists and will prevent regression

#### Phase 3: GREEN - Minimal Fix
1. Implement the **minimal code change** to make the test pass
2. Fix only what's needed to address the failing test
3. Avoid scope creep - don't refactor or add features during bug fixes
4. Run all tests to ensure the bug is fixed and nothing else breaks

#### Phase 4: REFACTOR - Code Review (Optional)
1. Have user review the fix
2. Only refactor if the fix introduced code smells
3. Keep changes minimal and focused on the bug

#### Phase 5: VERIFY - Run All Tests
1. Run full test suite to ensure no regressions
2. Verify coverage remains **≥ 90%**
3. Confirm the bug test now passes

## Spec Creation and Task List Rules

### Task List Testing Requirements

When creating task lists in specs, follow these strict rules:

#### REQUIRED Tasks for New Features (NEVER mark with `*`)
1. **Acceptance tests** - These are MANDATORY for new features (TDD Phase 1)
2. **Architecture tests** - Must verify layer compliance when adding new files/classes
3. **Core implementation** - The actual feature code
4. **Proto model updates** - When adding new gRPC endpoints

#### REQUIRED Tasks for Feature Enhancements (NEVER mark with `*`)
1. **Update existing tests** - Modify existing acceptance/integration tests to cover new behavior
2. **Core implementation** - The actual enhancement code
3. **Proto model updates** - When modifying gRPC endpoints

#### OPTIONAL Tasks (Mark with `*`)
1. **New acceptance tests** - Only if enhancement adds completely new use case not covered by existing tests
2. **Architecture tests** - Only if adding new files/classes during enhancement
3. **Property-based tests** - Enhancement beyond acceptance tests
4. **Additional unit tests** - Only if acceptance tests don't cover edge cases
5. **Integration tests** - Only if specifically requested by user
6. **Performance tests** - Only if specifically requested
7. **Documentation** - Unless it's API documentation required for the feature

#### Acceptance Test Structure in Task Lists

**CORRECT** - One test per use case:
```markdown
- [ ] 2. Write acceptance test for customer overview data retrieval
  - Test complete flow: User loads page → API fetches customer details → API fetches accounts → All data displays correctly
  - Verify customer personal information is fetched and displayed
  - Verify accounts portfolio is fetched and displayed
  - Verify error handling when API fails
  - Use test containers for infrastructure
  - Mock only external services
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3_
```

**INCORRECT** - Granular tests per function:
```markdown
- [ ]* 2.1 Write unit test for PersonalInformation component renders phone
- [ ]* 2.2 Write unit test for PersonalInformation component renders email
- [ ]* 2.3 Write unit test for PersonalInformation component renders address
- [ ]* 2.4 Write unit test for AccountsPortfolio component renders digital account
```

### Frontend vs Backend Acceptance Tests

**Backend Acceptance Tests**:
- Span from API controller → application service → SPI adapter → external service
- Use test containers for databases
- Mock external gRPC services
- Test complete use case flows

**Frontend Acceptance Tests**:
- Span from user interaction → component → API call → data display
- Use React Testing Library for component testing
- Use MSW (Mock Service Worker) for API mocking
- Test complete user flows, not individual components

### Frontend Test Selector Best Practices

When writing frontend acceptance tests, follow these selector guidelines to avoid flaky tests:

**DO**:
- Use `getByRole` with accessible names (e.g., `getByRole('button', { name: /submit/i })`)
- Use `getByLabelText` for form inputs
- Use `getByText` for unique text content (titles, descriptions, unique identifiers)
- Use `within()` to scope queries to specific regions (e.g., `within(drawer).getByRole(...)`)
- Use data-testid as a last resort for elements without semantic meaning

**DON'T**:
- Avoid using simple numeric IDs with `getByText` when they might appear in multiple places (badges, counts, table cells)
- Don't use CSS selectors or class names (they're implementation details)
- Don't query by element type alone (e.g., `getByRole('button')` without name)

**Example - Avoiding Ambiguous Selectors**:
```typescript
// ❌ BAD - ID "2" might appear in badge count AND table cell
const taskRow = screen.getByText(task.id).closest('[role="row"]');

// ✅ GOOD - Use unique text like title that only appears once
const taskRow = screen.getByText(task.title).closest('[role="row"]');

// ✅ GOOD - Use helper function for consistency
const getTaskRowByTask = (task) => {
  return screen.getByText(task.title).closest('[role="row"]');
};
```

**Example - Scoping Queries**:
```typescript
// ✅ GOOD - Scope to specific region to avoid ambiguity
const drawer = screen.getByRole('complementary', { name: /task workspace/i });
const taskDetails = within(drawer).getByRole('region', { name: /task details/i });
const claimButton = within(taskDetails).getByRole('button', { name: /claim/i });
```
