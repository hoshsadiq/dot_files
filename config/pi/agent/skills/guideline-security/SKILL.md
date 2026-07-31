---
name: guideline-security
description: "Security guidelines: authentication, authorization, input validation, secrets management."
---

# Security Guidelines

## See Also
- `code-review.md` - Security checks during code review
- `error-handling.md` - Safe error messages and logging

## Secrets Management

### Never Commit Secrets
- No API keys, tokens, passwords, or certificates in code
- No secrets in comments, TODOs, or test fixtures
- Use environment variables or secret management tools (Vault, AWS Secrets Manager, etc.)

### Files That Must Be in .gitignore
```
.env
.env.*
*.pem
*.key
*.p12
*.pfx
credentials.json
secrets.json
*_secret*
*_token*
*.keystore
serviceaccount*.json
```

### Secret Detection
Before committing, scan for secrets:
```bash
# Check staged files for common secret patterns
git diff --cached | grep -iE "(password|secret|token|api.key|private.key|BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY)" || echo "No secrets detected"
```

## Input Validation

### Validate at System Boundaries
- API controllers must validate all input parameters
- Never trust client-side validation alone
- Reject invalid input early with specific error messages

### Validation Patterns

```kotlin
// DO - Validate at the API boundary
fun createUser(request: CreateUserRequest): CreateUserResponse {
    require(request.email.matches(EMAIL_REGEX)) { "Invalid email format" }
    require(request.name.length in 1..255) { "Name must be 1-255 characters" }
    // ... proceed with validated input
}

// DON'T - Pass raw input to domain layer without validation
fun createUser(request: CreateUserRequest): CreateUserResponse {
    userService.create(request.email, request.name) // raw, unvalidated
}
```

### SQL Injection Prevention
- Use parameterized queries or ORM (JPA/Hibernate, Exposed, jOOQ)
- Never concatenate user input into SQL strings

```kotlin
// DO - Parameterized query
@Query("SELECT u FROM User u WHERE u.email = :email")
fun findByEmail(@Param("email") email: String): User?

// DON'T - String concatenation
@Query("SELECT u FROM User u WHERE u.email = '$email'")  // VULNERABLE
```

### XSS Prevention (Frontend)
- Use framework-provided escaping (React auto-escapes by default)
- Never use `dangerouslySetInnerHTML` without sanitization
- Sanitize user-generated content before rendering

```typescript
// DO - React auto-escapes
<p>{userInput}</p>

// DON'T - Raw HTML injection
<div dangerouslySetInnerHTML={{ __html: userInput }} />  // VULNERABLE
```

## Authentication and Authorization

### API Endpoints
- All endpoints require authentication unless explicitly public
- Use role-based access control (RBAC) at controller level
- Verify authorization before executing business logic, not after

### Token Handling
- Store tokens in secure, httpOnly cookies (not localStorage)
- Validate token expiry server-side
- Implement token refresh before expiry, not after failure

## Logging Security

### Never Log
- Passwords, tokens, API keys, or secrets
- Full credit card numbers, SSNs, or other PII
- Session tokens or authentication cookies
- Request/response bodies containing sensitive data

### Safe Logging Pattern
```kotlin
// DO - Log identifiers and actions, not sensitive data
logger.info("User login successful. userId={}", user.id)

// DON'T - Log sensitive data
logger.info("User login with password={}", password)  // NEVER
logger.info("API response: {}", responseBody)  // May contain PII
```

### Error Messages
- Internal error details must not leak to clients
- Log full stack traces server-side, return generic messages to clients

```kotlin
// DO - Generic client message, detailed server log
catch (e: DatabaseException) {
    logger.error("Database error processing request for userId={}", userId, e)
    throw ApiException("An error occurred. Please try again.", HttpStatus.INTERNAL_SERVER_ERROR)
}

// DON'T - Leak internals
catch (e: DatabaseException) {
    throw ApiException("Database error: ${e.message} on table ${e.tableName}", HttpStatus.INTERNAL_SERVER_ERROR)
}
```

## Dependency Security

### Keep Dependencies Updated
- Review dependency updates regularly (at least monthly)
- Prioritize security patches over feature updates
- Check for known vulnerabilities before adding new dependencies

### Vulnerability Scanning
```bash
# Gradle (Kotlin/Java)
./gradlew dependencyCheckAnalyze

# npm (TypeScript/JavaScript)
npm audit

# pip (Python)
pip-audit
```

### Supply Chain Considerations
- Pin dependency versions in production (no floating ranges)
- Verify checksums for critical dependencies
- Prefer well-maintained libraries with active security response teams
- Review transitive dependencies for known issues

## CORS and Headers

### CORS Configuration
- Never use `Access-Control-Allow-Origin: *` in production
- Whitelist specific origins
- Limit allowed methods and headers to what is needed

### Security Headers
Ensure responses include:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY` (or SAMEORIGIN if iframes needed)
- `Strict-Transport-Security` (HSTS)
- `Content-Security-Policy` (CSP)

## Common Security Mistakes

1. Hardcoded secrets in source code or configuration files
2. Missing input validation at API boundaries
3. SQL queries built by string concatenation
4. Logging sensitive data (passwords, tokens, PII)
5. Exposing internal error details to clients
6. Using `*` for CORS origins in production
7. Storing tokens in localStorage instead of httpOnly cookies
8. Not scanning dependencies for known vulnerabilities
9. Missing authorization checks on endpoints
10. Trusting client-side validation without server-side verification
