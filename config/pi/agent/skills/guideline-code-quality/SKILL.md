---
name: guideline-code-quality
description: "Code quality standards: KISS, SOLID, logging, naming conventions, and code simplicity rules."
---

# Code Quality Guidelines

> Source: projectcore/CODEGEN-GUIDELINE.md

## See Also
- `error-handling.md` - Error handling patterns
- `testing-backend.md` - Testing for quality assurance

## Code Quality Standards

- **Principles**: KISS (Keep It Simple, Stupid) and SOLID principles
  - Keep code simple and readable
  - Single Responsibility Principle: Each class has one reason to change
  - Open/Closed Principle: Open for extension, closed for modification
  - Liskov Substitution Principle: Subtypes must be substitutable
  - Interface Segregation Principle: Clients depend on specific interfaces
  - Dependency Inversion Principle: Depend on abstractions, not concretions

## Common Mistakes to Avoid

### For New Features:
1. ❌ **Not copying CODEGEN-GUIDELINE.md to `.kiro/steering/` before starting** (CRITICAL)
2. ❌ Creating classes in wrong layers (violates architecture)
3. ❌ Skipping acceptance tests (breaks TDD flow)
4. ❌ **Marking acceptance tests as optional in task lists** (they are REQUIRED for new features)
5. ❌ **Writing granular unit tests instead of use case-level acceptance tests**
6. ❌ Not running architecture tests (catches violations early)
7. ❌ Implementing too much in Phase 4 (defeats TDD purpose)
8. ❌ Forgetting to update proto models for new gRPC endpoints
9. ❌ Not achieving 90% coverage on new code
10. ❌ Accessing application layer from other layers
11. ❌ Creating full integration tests that spin up entire application (use acceptance tests instead)
12. ❌ Creating separate SPI unit tests (they're covered by acceptance tests)
13. ❌ Over-mocking in acceptance tests (defeats the purpose of testing real behavior)
14. ❌ **Creating one test per function instead of one test per use case**

### For Feature Enhancements:
1. ❌ Creating new acceptance tests when existing tests can be reused/enhanced
2. ❌ Running architecture tests when no new files/classes are added
3. ❌ Not updating existing tests to reflect new behavior
4. ❌ Ignoring existing integration tests that already cover the feature
5. ❌ Breaking existing test coverage when modifying code

### For Bug Fixes:
1. ❌ **Fixing the bug before writing a failing test** (breaks test-first approach)
2. ❌ **Not replicating the bug in tests** (allows regression)
3. ❌ Skipping existing test analysis (may miss related test coverage)
4. ❌ Over-fixing - changing more than needed to pass the test
5. ❌ Adding features or refactoring during bug fixes (scope creep)
6. ❌ Not running full test suite after fix (may introduce regressions)
7. ❌ Writing isolated unit tests when acceptance tests would better cover the bug scenario

## Linting and Code Quality Checks

### Automatic Lint Checks After Code Modifications
After completing any task that modifies code:

1. **Check for linting scripts**: Look for lint scripts in service-specific directories (e.g., `/services/customer-management-service/scripts/`) or in project build files
2. **Run available linters**: Execute any available linting commands (e.g., `./services/customer-management-service/scripts/lint.sh`, `npm run lint`, `./gradlew ktlintCheck`)
3. **Fix lint issues**: If lint errors are found, fix them before considering the task complete
4. **Report results**: Inform the user of any lint issues found and fixed

> **Note**: Linting scripts are typically located in service-specific directories under `/services/[service-name]/scripts/`. If no linting scripts are found, skip this step. The goal is to catch and fix code quality issues early.

### 6. Type Safety and Code Quality Rules
- **Avoid `Any` type at all costs** - Use specific types to maintain type safety and prevent runtime errors
- **Avoid redundant comments** - Code should be self-documenting; only add comments when necessary to explain complex business logic or non-obvious decisions
- **Always use Domain-Driven Design principles** - Apply validation and business logic within domain entities and value objects, keeping business rules close to the data they govern
- **Always use Test-Driven Development (TDD) approach** - Write tests first, then implement the minimal code to make them pass, following the established TDD workflow phases
- **Use data class instead of @JvmInline** - Prefer data classes for value objects to maintain clarity and avoid potential issues with inline classes
- **Avoid using entire namespace in function declarations** - Use imports instead of fully qualified names in function signatures to improve readability
- **Format JSON variables for human readability** - When storing or logging JSON data, use proper formatting with indentation and line breaks to improve debugging and maintenance