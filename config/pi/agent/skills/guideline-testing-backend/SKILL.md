---
name: guideline-testing-backend
description: "Backend testing patterns: acceptance tests, coverage requirements, architecture tests."
---

# Backend Testing Guidelines

> Source: projectcore/CODEGEN-GUIDELINE.md

## See Also
- `tdd-workflow.md` - TDD workflow phases
- `hexagonal-arch.md` - Architecture rules that tests validate

## Test Coverage Requirements

- **Minimum Coverage**: 90% line coverage
- Verify coverage using your project's coverage tool

> **Note**: See [PROJECT-CONTEXT.md](PROJECT-CONTEXT.md) for project-specific coverage commands and report locations.

## Key Testing Patterns

### Acceptance Tests (Application → SPI) - **REQUIRED, NEVER OPTIONAL**
- **These are MANDATORY and must NEVER be marked as optional in task lists**
- Span from application layer through SPI layer with real dependencies (e.g., database)
- Use test containers or similar tools for infrastructure dependencies
- Mock only external services
- Minimal mocking to keep tests readable and maintainable
- Each test represents a **complete use case** with clear expectations
- **One acceptance test per user story/use case** - not per function or component
- **SPI layer coverage is included here** - no separate SPI unit tests needed
- **Frontend acceptance tests**: Use React Testing Library + MSW for API mocking, test complete user flows

### API Layer Unit Tests - **OPTIONAL (only if needed beyond acceptance tests)**
- Narrow tests verifying request → api port interface mapping
- Mock the api port interfaces
- Verify correct data transformation and port invocation
- Keep these lightweight (no containers)
- **Only create these if acceptance tests don't provide sufficient coverage**

#### Controller Unit Testing Guidelines
When writing controller unit tests, focus on testing the controller's actual logic, not just mock verification:

**DO - Test Controller Logic:**
- **Parameter validation**: Verify controller validates input parameters correctly
- **Exception handling**: Test that controller properly handles exceptions from application layer
- **Request/Response mapping**: Verify correct transformation between gRPC/HTTP and domain models
- **Status code mapping**: Ensure proper HTTP status codes or gRPC status codes are returned
- **Error message formatting**: Verify error messages are properly formatted for clients

**DON'T - Mock and Assert Same Data:**
- ❌ **Anti-pattern**: Mock use case to return specific data, then assert controller returns same mocked data
- ❌ **No value**: `every { useCase.method() } returns mockData` followed by `assertThat(response).isEqualTo(mockData)`
- ❌ **Circular testing**: This only tests that mocks work, not that controller logic works

**Example - WRONG Approach:**
```kotlin
// ❌ BAD - Mocking return value then asserting the same value
every { getCaseDetailUseCase.getCaseDetail(CaseId(validCaseId)) } returns domainCaseDetail
controller.getCaseDetail(request, responseObserver)
verify { responseObserver.onNext(capture(responseSlot)) }
assertThat(responseSlot.captured.caseDetail.caseId).isEqualTo(validCaseId) // Just asserting mocked data
```

**Example - CORRECT Approach:**
```kotlin
// ✅ GOOD - Testing actual controller logic
@Test
fun `should return INVALID_ARGUMENT when case ID format is invalid`() {
    val invalidCaseId = "not-a-uuid"
    val request = GetCaseDetailRequest.newBuilder().setCaseId(invalidCaseId).build()
    
    controller.getCaseDetail(request, responseObserver)
    
    verify { responseObserver.onError(capture(exceptionSlot)) }
    assertThat(exceptionSlot.captured.status.code).isEqualTo(Status.Code.INVALID_ARGUMENT)
    assertThat(exceptionSlot.captured.status.description).contains("Invalid case ID format")
    // This tests controller's validation logic, not mocked data
}

@Test
fun `should map CaseNotFoundException to NOT_FOUND status`() {
    val caseId = UUID.randomUUID().toString()
    every { getCaseDetailUseCase.getCaseDetail(any()) } throws CaseNotFoundException(caseId)
    
    controller.getCaseDetail(request, responseObserver)
    
    verify { responseObserver.onError(capture(exceptionSlot)) }
    assertThat(exceptionSlot.captured.status.code).isEqualTo(Status.Code.NOT_FOUND)
    // This tests controller's exception handling logic
}
```

**Focus Areas for Controller Tests:**
1. **Input validation** - Test invalid formats, missing required fields, boundary conditions
2. **Exception mapping** - Test that domain exceptions are properly converted to appropriate HTTP/gRPC status codes
3. **Request parsing** - Verify controller correctly extracts data from requests
4. **Response formatting** - Test that responses are properly structured (but don't just assert mocked data)
5. **Security validation** - Test authentication/authorization logic if present in controller

**When Controller Tests Add Value:**
- Controller has complex validation logic beyond simple null checks
- Controller performs data transformation or formatting
- Controller has specific error handling or status code mapping
- Controller has authentication/authorization logic
- Acceptance tests don't cover all controller error scenarios

**When to Skip Controller Tests:**
- Controller is a simple pass-through to application layer
- All controller behavior is already covered by acceptance tests
- Controller only does basic request/response mapping with no logic

### Architecture Tests - **REQUIRED**
- Automatically enforced on every build
- Verify layer access rules and dependencies
- Must pass before any code is merged

### ⚠️ Avoid Full Integration Tests unless user specifically requested
- Do NOT create separate integration tests that spin up full application instances
- Acceptance tests already provide comprehensive coverage with containers
- Full integration tests are costly and slow - use acceptance tests instead

### 4. Mapper Testing Guidelines
Mappers (data transformation classes) should be tested through acceptance tests, not isolated unit tests:
- **Do NOT create isolated unit tests for mappers** - Mappers are simple data transformation logic
- **Mappers are covered by acceptance tests** - Acceptance tests verify the complete data flow including mapping
- **Exception**: If mapper unit tests already exist, enhance them as needed
- **Property-based tests for mappers**: Only create property-based tests at the acceptance test level, not for isolated mapper unit tests
- This reduces test maintenance burden and focuses on end-to-end correctness

### 9. Testing Architecture Violations Prevention

When reviewing or refactoring existing tests, watch for these specific anti-patterns that violate comprehensive testing guidelines:

### 9. Testing Architecture Violations Prevention

#### Anti-Pattern: Tab Switching Micro-Tests
**❌ WRONG - Granular tests for same user workflow:**
```typescript
// DON'T create separate tests for each aspect of tab switching
it('displays only assigned tasks when My Tasks tab is clicked');
it('displays task titles for assigned tasks'); 
it('displays correct task data in table columns');
```

**✅ CORRECT - One comprehensive test:**
```typescript
// CREATE one comprehensive test covering complete tab switching workflow
it('handles comprehensive My Tasks tab workflow with complete data display', () => {
  // Test: tab switching + data filtering + all column display + task visibility
});
```

#### Anti-Pattern: Display Verification Micro-Tests
**❌ WRONG - Separate tests for each display element:**
```typescript
// DON'T create separate tests for each field display
it('displays case count in the tab badge');
it('displays all required columns in the cases table');
it('displays priority colors correctly across all views');
it('displays status badge colors correctly across all views');
```

**✅ CORRECT - Consolidated display tests:**
```typescript
// CREATE comprehensive tests that verify complete UI state
it('displays comprehensive case information with all visual indicators', () => {
  // Test: table display + columns + badges + colors + counts in one test
});
```

#### Anti-Pattern: Implementation Detail Testing
**❌ WRONG - Testing internal component structure:**
```typescript
// DON'T test CSS classes, component props, or internal state
expect(element).toHaveClass('MuiChip-root');
expect(component.state.isLoading).toBe(false);
```

**✅ CORRECT - Test user-visible behavior:**
```typescript
// TEST what users see and can interact with
expect(screen.getByRole('button', { name: /claim/i })).toBeInTheDocument();
expect(screen.getByText('Task claimed successfully')).toBeInTheDocument();
```

#### Common Testing Architecture Violations to Fix
1. **Multiple tests for same user journey** - Consolidate into comprehensive workflow tests
2. **Separate tests for each field/column** - Test complete data display in one test
3. **Testing CSS classes or component internals** - Focus on user-visible behavior
4. **Micro-assertions split across tests** - Group related assertions in comprehensive tests
5. **Testing framework behavior** - Don't test React/MUI functionality, test your app logic

#### Prevention Guidelines (Primary Goal)
**Before writing any test, ask these questions:**
1. **Does this test represent a complete user workflow?** If not, expand it or combine with related tests
2. **Am I testing the same user action multiple times?** Consolidate into one comprehensive test
3. **Would a real user perform these actions together?** If yes, test them together
4. **Am I testing implementation details?** Focus on user-visible behavior instead
5. **Does this test add unique value?** Avoid redundant tests that verify the same behavior

**Test Generation Decision Framework:**
- **One test per user scenario** - Not one test per field/property/function
- **Complete workflows over micro-interactions** - Test end-to-end user journeys
- **User behavior over component internals** - Test what users see and do
- **Realistic scenarios over artificial edge cases** - Focus on actual usage patterns

#### Refactoring Guidelines (When Violations Already Exist)
When consolidating existing granular tests:
1. **Identify the core user workflow** being tested across multiple granular tests
2. **Combine setup and actions** that are identical across tests
3. **Group all related assertions** into comprehensive verification blocks
4. **Maintain clear test structure** with GIVEN/WHEN/THEN comments
5. **Keep test names descriptive** of the complete workflow being tested

**The goal is prevention through proper test design, not post-hoc consolidation.**
