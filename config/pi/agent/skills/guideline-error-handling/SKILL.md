---
name: guideline-error-handling
description: "Error handling patterns: exception hierarchy, error responses, logging, and retry strategies."
---

# Error Handling Guidelines

> Source: projectcore/CODEGEN-GUIDELINE.md

## See Also
- `code-quality.md` - General code quality standards
- `hexagonal-arch.md` - Service layer architecture

### 1. Exception for Logging/Exception-Only Changes
No acceptance tests (and no Phase 1) are required when the change is only:
- Adding or modifying log statements (no tests needed)
- Changing exception messages (unit tests required to verify correct error messages)
- Adding new exception classes that are already thrown in existing flows (unit tests required)
- Pure defensive null checks that only throw (unit tests required)

In these cases:
- Skip Phase 1 (acceptance tests) completely
- Write isolated unit tests to ensure correct exception behavior and messages
- Logs do not need tests
- Write in the commit message: `No acceptance tests – logging/exception-only change`

### 5. Error Handling Implementation Guidelines

When implementing user-facing functionality, always include proper error handling:

#### Frontend Error Handling Requirements
- **Form Validation**: Add client-side validation with user-friendly error messages
- **Async Operations**: Handle loading states, success, and error states for all async operations
- **User Feedback**: Display errors in UI with proper styling and clear messaging
- **Graceful Degradation**: Ensure functionality continues to work even when non-critical errors occur

#### Hook Error Handling Pattern
```typescript
// ✅ GOOD - Comprehensive error handling in custom hooks
export const useTaskActions = (initialTasks: Task[]) => {
  const [tasks, setTasks] = useState<Task[]>(initialTasks);
  const [error, setError] = useState<string | null>(null);

  const claimTask = useCallback((taskId: string): { success: boolean; error?: string } => {
    setError(null);
    
    // Validate input
    const existingTask = tasks.find(task => task.id === taskId);
    if (!existingTask) {
      const errorMsg = `Task with ID ${taskId} not found`;
      setError(errorMsg);
      return { success: false, error: errorMsg };
    }
    
    // Perform operation
    // ... implementation
    
    return { success: true };
  }, [tasks]);

  return { tasks, claimTask, error, clearError: () => setError(null) };
};
```

#### Form Error Handling Pattern
```typescript
// ✅ GOOD - Form with comprehensive error handling
const [formError, setFormError] = useState<string | null>(null);
const [isSubmitting, setIsSubmitting] = useState(false);

const handleSubmit = async () => {
  setFormError(null);
  setIsSubmitting(true);

  try {
    // Validate required fields
    if (!formData.field) {
      throw new Error('Please fill in all required fields');
    }
    
    // Perform async operation
    await submitForm(formData);
    
    // Handle success
    onSuccess();
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Operation failed';
    setFormError(errorMessage);
  } finally {
    setIsSubmitting(false);
  }
};
```

#### Error Display Pattern
```typescript
// ✅ GOOD - Error display in UI
{formError && (
  <Box sx={{ 
    p: 2, 
    bgcolor: 'error.light', 
    color: 'error.contrastText', 
    borderRadius: 1,
    border: '1px solid',
    borderColor: 'error.main'
  }}>
    {formError}
  </Box>
)}
```

#### Common Error Handling Mistakes to Avoid
1. ❌ **No error handling for async operations** - Always handle both success and error cases
2. ❌ **Silent failures** - Always provide user feedback when operations fail
3. ❌ **Generic error messages** - Provide specific, actionable error messages
4. ❌ **No loading states** - Always show loading indicators for async operations
5. ❌ **Blocking errors for recoverable situations** - Use warnings for non-critical issues
6. ❌ **No input validation** - Always validate user input before processing
7. ❌ **Not clearing previous errors** - Clear error state before new operations

### 8. Service Layer Isolation Guidelines

When implementing service layers with mock data, ensure proper isolation to prevent test interference:

#### Service Instance Isolation
- **Create fresh service instances per hook**: Use factory functions and `useMemo` to create isolated service instances
- **Avoid shared service instances**: Don't export singleton service instances that share state across tests
- **Deep copy mock data**: Always create fresh copies of mock data in service constructors

#### Mock Service Implementation Pattern
```typescript
// ✅ CORRECT - Factory function with fresh instances
export class MockTaskService implements TaskService {
  private tasks: Task[];

  constructor() {
    // Always start with fresh copy of mock data to avoid test interference
    this.tasks = JSON.parse(JSON.stringify(mockTasks));
  }
   
  // ... service methods
}

export const createTaskService = (): TaskService => new MockTaskService();
export const taskService: TaskService = createTaskService(); // Default instance
```

#### Hook Implementation Pattern
```typescript
// ✅ CORRECT - Fresh service instance per hook
export const useTasks = () => {
  // Create a fresh service instance for each hook instance to avoid test interference
  const taskService = useMemo(() => createTaskService(), []);
   
  // ... hook implementation
};
```

#### Common Service Layer Mistakes to Avoid
1. ❌ **Shared service instances across tests** - Causes data mutations to persist between tests
2. ❌ **Shallow copying mock data** - `[...mockData]` doesn't prevent nested object mutations
3. ❌ **Service singletons with mutable state** - Tests interfere with each other's data
4. ❌ **Not resetting service state between tests** - Previous test actions affect subsequent tests
5. ❌ **Using class properties for mock data initialization** - `private tasks: Task[] = mockTasks` shares reference

#### Why This Pattern Is Required
- **Test isolation**: Each test gets fresh, unmodified mock data
- **Prevents flaky tests**: Eliminates data mutations that cause tests to fail intermittently
- **Predictable behavior**: Service operations don't affect other test instances
- **Easier debugging**: Test failures are isolated to the specific test, not side effects from other tests

#### Service Layer Testing Best Practices
- **Use service abstraction in components**: Components should use service interfaces, not direct mock data imports
- **Test service behavior through hooks**: Acceptance tests should verify service integration through React hooks
- **Mock external dependencies only**: Keep service layer synchronous when possible to avoid timing issues
- **Verify service isolation**: Ensure tests pass consistently when run in any order

This pattern ensures that service layers provide proper abstraction while maintaining test reliability and preventing data mutation issues that can cause intermittent test failures.

### 8. HTTP Client and Retry Mechanism Guidelines

When implementing API integration, always follow existing patterns:

#### Existing Retry Configuration
The project already has a standardized retry mechanism in `services/customer-view-web-app/src/shared/queryConfig.ts`:
- **Single retry on failure**: `retry: 1`
- **1 second retry delay**: `retryDelay: 1000`
- **Consistent across all API calls**: Use `defaultQueryOptions` for all queries

#### HTTP Client Usage
- **Use existing axios instance**: Import from `services/customer-view-web-app/src/api/axios.ts`
- **Consistent configuration**: Base URL, credentials, parameter serialization already configured
- **Built-in logging**: Request interceptor already logs API calls for debugging

#### Implementation Pattern
```typescript
// ✅ CORRECT - Use existing query configuration
import { defaultQueryOptions } from '@/shared/queryConfig';

const query = useList({
  resource: RESOURCES.CASES,
  queryOptions: defaultQueryOptions, // Includes retry mechanism
});

// ✅ CORRECT - Use existing axios instance
import { axiosInstance } from '@/api/axios';

const response = await axiosInstance<CaseResponse>({
  method: 'GET',
  url: '/api/v1/case-management-service/cases',
  params: { customerId, status, priority }
});
```

#### Common Mistakes to Avoid
1. ❌ **Creating custom retry logic** - Use existing `defaultQueryOptions` instead
2. ❌ **Different retry configurations** - Maintain consistency across the application
3. ❌ **Custom axios instances** - Use the existing `axiosInstance` function
4. ❌ **Ignoring existing error handling** - Follow established patterns for API errors
