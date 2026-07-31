---
name: guideline-testing-frontend
description: "Frontend testing patterns: component tests, integration tests, mocking, and i18n testing."
---

# Frontend Testing Guidelines

> Source: projectcore/CODEGEN-GUIDELINE.md

## See Also
- `tdd-workflow.md` - TDD workflow phases
- `code-quality.md` - General code quality standards

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

## Frontend Testing Guidelines

Follow these guidelines to generate high-quality, non-redundant test suites from the start:

### Test Generation Principles

#### 1. Comprehensive Tests Over Granular Tests
**DO**: Write comprehensive tests that verify complete user flows and multiple related behaviors in a single test
**DON'T**: Write separate tests for each individual field, property, or minor variation

**Example - Comprehensive Approach**:
```typescript
// ✅ GOOD - One comprehensive test covering all case information display
it('displays comprehensive case information when case is selected', async () => {
  // Test covers: case ID, title, description, created date, updated date, assignee, priority, status
  // All verified in one cohesive test that represents actual user behavior
});
```

**Example - Granular Approach (AVOID)**:
```typescript
// ❌ BAD - Separate tests for each field (creates maintenance burden)
it('displays case ID when case is selected');
it('displays case title when case is selected');
it('displays case description when case is selected');
it('displays case created date when case is selected');
// ... 5+ more similar tests
```

#### 2. Generate Comprehensive Tests Instead of Granular Patterns
Avoid generating multiple tests that follow the same pattern with only minor variations:

**Generate Single Comprehensive Tests For**:
- **Field Display**: One test covering all fields in a form/display instead of separate field tests
- **Color/Style Variations**: One test covering all color states instead of separate color tests
- **Similar Interactions**: One test covering related user actions instead of separate interaction tests
- **Related Error Scenarios**: One test covering error handling workflow instead of separate error tests
- **State Changes**: One test covering complete state workflow instead of separate state tests

**Example - Wrong Approach**:
```typescript
// ❌ DON'T GENERATE - Multiple granular tests for priority colors
it('displays critical priority with red color');
it('displays high priority with orange color');
it('displays medium priority with yellow color');
it('displays low priority with green color');
it('displays info priority with blue color');
```

**Example - Correct Approach**:
```typescript
// ✅ GENERATE - One comprehensive test covering all priority colors
it('displays correct priority colors across all priority levels', () => {
  // Test all priority levels and their colors in one comprehensive test
  // Covers both case list view and task detail view
});
```

#### 3. Eliminate Tests with No Value
Remove or avoid creating tests that:
- **Duplicate existing coverage**: Tests that verify the same behavior as other tests
- **Test implementation details**: Tests that verify internal component structure rather than user-visible behavior
- **Test trivial behavior**: Tests for basic React rendering without meaningful assertions
- **Test framework behavior**: Tests that verify React Testing Library or testing framework functionality

**Examples of No-Value Tests**:
```typescript
// ❌ NO VALUE - Tests basic React rendering
it('renders without crashing');

// ❌ NO VALUE - Tests implementation detail
it('has correct CSS class names');

// ❌ NO VALUE - Duplicates other test coverage
it('displays case title in sidebar'); // If already tested in comprehensive display test
```

#### 4. Use Proper Test Selectors
Follow selector best practices to avoid flaky tests:

**Recommended Selector Priority**:
1. **Semantic queries**: `getByRole`, `getByLabelText`, `getByText` (for unique content)
2. **Scoped queries**: Use `within()` to limit scope and avoid ambiguity
3. **Data attributes**: `getByTestId` as last resort

**Avoid Ambiguous Selectors**:
```typescript
// ❌ BAD - Ambiguous selector (ID might appear in multiple places)
const taskRow = screen.getByText(task.id).closest('[role="row"]');

// ✅ GOOD - Use unique, descriptive text
const taskRow = screen.getByText(task.title).closest('[role="row"]');

// ✅ GOOD - Scope to specific region
const drawer = screen.getByRole('complementary', { name: /task workspace/i });
const taskDetails = within(drawer).getByRole('region', { name: /task details/i });
```

#### 5. Test Organization Patterns

**Group Related Tests**:
```typescript
describe('Case Information Display', () => {
  // All case display tests together
  it('displays comprehensive case information when case is selected');
  it('handles missing case data gracefully');
});

describe('User Interactions', () => {
  // All interaction tests together
  it('handles sidebar close functionality comprehensively');
  it('handles click outside sidebar to close');
});
```

**Avoid Over-Nesting**:
```typescript
// ❌ BAD - Over-nested describe blocks
describe('CasesListPage', () => {
  describe('when case is selected', () => {
    describe('case information', () => {
      describe('case ID', () => {
        it('displays case ID');
      });
    });
  });
});

// ✅ GOOD - Flat, descriptive structure
describe('CasesListPage', () => {
  it('displays comprehensive case information when case is selected');
});
```

### Frontend Test Quality Checklist

Before creating or reviewing frontend tests, verify:

- [ ] **No redundant tests**: Each test verifies unique behavior not covered elsewhere
- [ ] **Comprehensive over granular**: Tests cover complete user flows rather than individual properties
- [ ] **Proper selectors**: Uses semantic queries and avoids ambiguous selectors
- [ ] **Clear test names**: Test names describe user behavior, not implementation details
- [ ] **Minimal mocking**: Only mock external dependencies, not internal components
- [ ] **Realistic scenarios**: Tests represent actual user workflows
- [ ] **Maintainable assertions**: Assertions focus on user-visible behavior
- [ ] **Consolidated patterns**: Similar test patterns are merged into comprehensive tests

### When to Create Separate Tests

Create separate tests only when:
- **Different user workflows**: Tests represent genuinely different user scenarios
- **Different error conditions**: Each test covers a distinct error case
- **Different component states**: Tests verify behavior in meaningfully different states
- **Performance considerations**: Comprehensive tests become too slow or complex

### Test Generation Decision Framework

Use this framework when deciding what tests to generate:

#### Generate One Comprehensive Test When:
- Multiple behaviors have **identical setup** (same component, same initial state)
- Multiple behaviors verify **related functionality** (all fields in a form, all aspects of an action)
- Multiple behaviors follow **similar patterns** ("displays X", "handles Y", "shows Z")
- Multiple behaviors represent **the same user journey** with minor variations
- Multiple behaviors would **naturally be performed together** by a real user

#### Generate Separate Tests When:
- Tests represent **fundamentally different user goals**
- Tests require **significantly different setup** or test data
- Tests verify **independent error conditions** that don't relate to each other
- Tests cover **different user roles** or permissions
- Combining them would make the test **too complex** or **hard to debug**

#### Example Decision Process:
```typescript
// QUESTION: Should I generate separate tests for each field?
// POTENTIAL TESTS:
// it('displays task title in sidebar');
// it('displays task status in sidebar');
// it('displays task assignee in sidebar');

// ANALYSIS:
// ✅ Same setup (open task sidebar)
// ✅ Related functionality (all task information display)
// ✅ Same user journey (user wants to see task details)
// ✅ Would naturally be checked together

// DECISION: Generate ONE comprehensive test
it('displays comprehensive task information in sidebar');
```

```typescript
// QUESTION: Should I generate one test for both workflows?
// POTENTIAL TESTS:
// it('handles task claiming workflow');
// it('handles task deletion workflow');

// ANALYSIS:
// ❌ Different user goals (claim vs delete)
// ❌ Different outcomes and side effects
// ❌ Independent actions that don't relate

// DECISION: Generate SEPARATE tests for each workflow
```

### Redundant Test Generation Red Flags

Avoid generating tests with these patterns:
- Multiple tests with nearly identical setup and assertions
- Tests that differ only in the specific field or property being verified
- Tests that follow the pattern "displays X when Y" for multiple values of X
- Tests that verify the same user workflow with minor variations
- Tests that should be combined into comprehensive workflows without losing meaningful coverage

### Specific Anti-Patterns to Avoid

Based on consolidation exercises, avoid these specific redundant test patterns:

#### 1. Individual Field Display Tests
**❌ AVOID**: Separate tests for each field in a form, sidebar, or display component
```typescript
// DON'T create separate tests for each field
it('displays task title in sidebar');
it('displays task status in sidebar');
it('displays task assignee in sidebar');
it('displays task priority in sidebar');
it('displays task due date in sidebar');
```

**✅ DO**: One comprehensive test covering all fields
```typescript
// CREATE one comprehensive test
it('displays comprehensive task information in sidebar', () => {
  // Test all fields: title, status, assignee, priority, due date in one test
});
```

#### 2. Action Workflow Granular Tests
**❌ AVOID**: Breaking down user actions into micro-tests
```typescript
// DON'T create separate tests for each aspect of an action
it('claims task when work on task button is clicked');
it('updates task status to Assigned after claiming');
it('sets assignee to current user after claiming');
it('logs task claim details to console');
```

**✅ DO**: One comprehensive workflow test
```typescript
// CREATE one comprehensive workflow test
it('handles complete task claiming workflow when work on task button is clicked', () => {
  // Test entire workflow: click button → task claimed → status updated → assignee set → logging
});
```

#### 3. State Variation Micro-Tests
**❌ AVOID**: Separate tests for minor state variations
```typescript
// DON'T create separate tests for each state variation
it('displays claim button for unassigned tasks');
it('does not display release button for unassigned tasks');
it('allows claiming task from sidebar');
```

**✅ DO**: One comprehensive state test
```typescript
// CREATE one comprehensive state test
it('handles comprehensive unassigned task state and interactions', () => {
  // Test all aspects: button visibility, interactions, state changes
});
```

#### 4. Filter/Search Granular Tests
**❌ AVOID**: Separate tests for each filter type
```typescript
// DON'T create separate tests for each filter
it('clears status filter when switching tabs');
it('clears priority filter when switching tabs');
it('clears search input when switching tabs');
it('resets sort configuration when switching tabs');
```

**✅ DO**: One comprehensive filter reset test
```typescript
// CREATE one comprehensive filter test
it('handles comprehensive filter reset behavior when switching tabs', () => {
  // Test all filters: status, priority, search, sorting in one test
});
```

#### 5. Visual Indicator Micro-Tests
**❌ AVOID**: Separate tests for each visual state
```typescript
// DON'T create separate tests for each color/style
it('displays critical priority with red color');
it('displays high priority with orange color');
it('displays medium priority with yellow color');
```

**✅ DO**: One comprehensive visual test
```typescript
// CREATE one comprehensive visual test
it('displays correct priority colors across all priority levels', () => {
  // Test all priority colors and contexts in one test
});
```

### Benefits of Comprehensive Test Generation

Generating comprehensive tests from the start provides:
- **Reduced maintenance burden**: Fewer tests to update when UI changes
- **Faster test execution**: Fewer test cases to run
- **Better readability**: Tests represent actual user scenarios
- **Improved coverage quality**: Focus on meaningful user behavior rather than implementation details
- **Easier debugging**: Comprehensive tests provide better context when failures occur

### Code Generation Test Rules

When generating frontend tests, follow these strict rules:

#### Rule 1: One Test Per User Scenario
- **DO NOT** generate separate tests for each field, property, or UI element
- **DO** generate one comprehensive test per complete user workflow
- **Example**: Instead of 5 tests for "displays case ID", "displays case title", etc., generate 1 test for "displays comprehensive case information"

#### Rule 2: Consolidate Similar Patterns
- **DO NOT** generate multiple tests that follow the same pattern with different values
- **DO** generate one test that covers all variations of the pattern
- **Example**: Instead of separate color tests for each priority level, generate 1 test covering all priority colors

#### Rule 3: Test Complete Workflows
- **DO NOT** break user actions into micro-steps with separate tests
- **DO** test the complete user workflow from start to finish
- **Example**: Instead of separate tests for "clicks button", "updates status", "logs action", generate 1 test for "handles complete workflow"

#### Rule 4: Avoid Implementation Detail Tests
- **DO NOT** generate tests that verify internal component structure
- **DO** generate tests that verify user-visible behavior and outcomes
- **Example**: Don't test CSS classes or component props, test what the user sees and can interact with

#### Rule 5: Use Realistic Test Scenarios
- **DO NOT** generate artificial test scenarios that users would never encounter
- **DO** generate tests that represent actual user workflows and goals
- **Example**: Test "user wants to see case details" rather than "component renders case ID field"

By following these guidelines, frontend tests will be more maintainable, reliable, and focused on delivering value rather than creating maintenance overhead.

### Test Generation Checklist

Before generating any frontend test, verify:
- [ ] Does this test represent a complete user scenario?
- [ ] Can this be consolidated with other similar tests?
- [ ] Does this test verify user-visible behavior (not implementation details)?
- [ ] Would a real user perform this action in isolation?
- [ ] Does this test add unique value not covered elsewhere?

If any answer is "No", consolidate or redesign the test approach.

#### Common i18n Mistakes to Avoid
1. ❌ **Not mocking i18n in test environment** - Tests will show translation keys instead of translated text
2. ❌ **Using hardcoded text in test assertions after adding i18n** - Tests will fail when components use translation keys
3. ❌ **Creating nested translation key structures** - Harder to maintain and type-check
4. ❌ **Forgetting to add keys to all language files** - Missing translations will show as keys
5. ❌ **Not updating existing tests when adding i18n** - All text-based assertions need to use translation keys
6. ❌ **Importing wrong i18n instance in components** - Use main i18n instance, not testI18n
7. ❌ **Not using `testI18n.t()` in test assertions** - Tests should verify translated text, not raw keys
8. ❌ **Mismatched testI18n configuration** - testI18n config must match expected values in i18n configuration tests
9. ❌ **Testing main i18n config without understanding test mocking** - vitest.setup.ts mocks main i18n with testI18n
10. ❌ **Using i18n.t() in column definitions at module load time** - Use factory functions that accept translation function instead
11. ❌ **CRITICAL: Using direct i18n.t() calls in React components** - Import `useTypeSafeTranslation` hook instead of direct i18n instance

#### i18n Implementation Workflow
1. **Add translation keys** to all language files (`en/common.json`, `ar/common.json`)
2. **Update components** to use `i18n.t()` instead of hardcoded strings
3. **Mock i18n in test setup** to use testI18n instance
4. **Update all test assertions** to use `testI18n.t()` for translated text
5. **Ensure testI18n configuration matches main i18n config** - Critical for configuration tests
6. **Run tests** to verify i18n integration works correctly
7. **Test language switching** in the actual application

#### i18n Configuration Testing Guidelines
When testing i18n configuration:
- **Understand the test environment**: `vitest.setup.ts` mocks the main i18n instance with `testI18n`
- **Keep testI18n config in sync**: The `test-i18n.ts` configuration must match expected values in configuration tests
- **Required testI18n settings** for configuration tests to pass:
  ```typescript
  {
    supportedLngs: ['en', 'ar'],
    fallbackLng: ['en'],
    load: 'languageOnly',
    react: { useSuspense: true },
    detection: {
      order: ['path', 'localStorage', 'navigator'],
      // ... other detection config
    }
  }
  ```
- **Configuration test failures**: Usually indicate mismatch between main i18n config and testI18n config
- **Follow existing patterns**: Check how other modules handle i18n testing (e.g., customers module uses `testI18n.t()`)