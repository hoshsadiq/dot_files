# Authentication Patterns

Login flows, session persistence, OAuth, 2FA, and authenticated browsing.

**Related**: [session-management.md](session-management.md) for state persistence details, [SKILL.md](../SKILL.md) for quick start.

## Contents

- [Import Auth from Your Browser](#import-auth-from-your-browser)
- [Persistent Profiles](#persistent-profiles)
- [Session Persistence](#session-persistence)
- [Basic Login Flow](#basic-login-flow)
- [Saving Authentication State](#saving-authentication-state)
- [Restoring Authentication](#restoring-authentication)
- [OAuth / SSO Flows](#oauth--sso-flows)
- [Two-Factor Authentication](#two-factor-authentication)
- [HTTP Basic Auth](#http-basic-auth)
- [Cookie-Based Auth](#cookie-based-auth)
- [Token Refresh Handling](#token-refresh-handling)
- [Security Best Practices](#security-best-practices)

## Import Auth from Your Browser

The fastest way to reuse an authenticated Chrome session:

1. **Launch Chrome with remote debugging:**
   ```bash
   # macOS
   open -na "Google Chrome" --args --remote-debugging-port=9222 --user-data-dir="$HOME/chrome-debug-profile"
   # Linux
   google-chrome --remote-debugging-port=9222 --user-data-dir="$HOME/chrome-debug-profile"
   ```

   If you use `--user-data-dir`, Chrome starts with a separate profile. Log into the target site in that browser window before continuing. If you already have Chrome running with remote debugging on your normal profile, you can reuse that instead.

2. **Grab the authenticated state:**
   ```bash
   agent-browser --auto-connect state save ./browser-auth.json
   ```

3. **Reuse in automation:**
   ```bash
   agent-browser --state ./browser-auth.json open https://app.example.com/dashboard
   ```

## Persistent Profiles

Use `--profile` to point at a Chrome user-data directory. All cookies, localStorage, extensions, and settings persist across runs:

```bash
# First run — login manually or programmatically
agent-browser --profile ./browser-data open https://app.example.com/login
# ... login flow ...
agent-browser close

# Subsequent runs — already authenticated
agent-browser --profile ./browser-data open https://app.example.com/dashboard
```

The directory is a standard Chrome user-data dir, so you can also pre-seed it by launching Chrome directly with `--user-data-dir`.

## Session Persistence

Use `--session-name` to automatically save and restore cookies and localStorage across browser restarts:

```bash
# First run — login and state is auto-saved on close
agent-browser --session-name myapp open https://app.example.com/login
# ... login flow ...
agent-browser close  # State auto-saved to ~/.agent-browser/sessions/

# Next run — state is auto-loaded
agent-browser --session-name myapp open https://app.example.com/dashboard
```

Session state is stored in `~/.agent-browser/sessions/`. Add `AGENT_BROWSER_ENCRYPTION_KEY` to encrypt state at rest.

## Basic Login Flow

```bash
# Navigate to login page
agent-browser open https://app.example.com/login
agent-browser wait --load networkidle

# Get form elements
agent-browser snapshot -i
# Output: @e1 [input type="email"], @e2 [input type="password"], @e3 [button] "Sign In"

# Fill credentials
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"

# Submit
agent-browser click @e3
agent-browser wait --load networkidle

# Verify login succeeded
agent-browser get url  # Should be dashboard, not login
```

## Saving Authentication State

After logging in, save state for reuse:

```bash
# Login first (see above)
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --url "**/dashboard"

# Save authenticated state
agent-browser state save ./auth-state.json
```

## Restoring Authentication

Skip login by loading saved state:

```bash
# Load saved auth state
agent-browser state load ./auth-state.json

# Navigate directly to protected page
agent-browser open https://app.example.com/dashboard

# Verify authenticated
agent-browser snapshot -i
```

## OAuth / SSO Flows

For OAuth redirects:

```bash
# Start OAuth flow
agent-browser open https://app.example.com/auth/google

# Handle redirects automatically
agent-browser wait --url "**/accounts.google.com**"
agent-browser snapshot -i

# Fill Google credentials
agent-browser fill @e1 "user@gmail.com"
agent-browser click @e2  # Next button
agent-browser wait 2000
agent-browser snapshot -i
agent-browser fill @e3 "password"
agent-browser click @e4  # Sign in

# Wait for redirect back
agent-browser wait --url "**/app.example.com**"
agent-browser state save ./oauth-state.json
```

## Two-Factor Authentication

Handle 2FA with manual intervention:

```bash
# Login with credentials
agent-browser open https://app.example.com/login --headed  # Show browser
agent-browser snapshot -i
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3

# Wait for user to complete 2FA manually
echo "Complete 2FA in the browser window..."
agent-browser wait --url "**/dashboard" --timeout 120000

# Save state after 2FA
agent-browser state save ./2fa-state.json
```

## HTTP Basic Auth

For sites using HTTP Basic Authentication:

```bash
# Set credentials before navigation
agent-browser set credentials username password

# Navigate to protected resource
agent-browser open https://protected.example.com/api
```

## Cookie-Based Auth

Manually set authentication cookies:

```bash
# Set auth cookie
agent-browser cookies set session_token "abc123xyz"

# Navigate to protected page
agent-browser open https://app.example.com/dashboard
```

## Token Refresh Handling

For sessions with expiring tokens:

```bash
#!/bin/bash
# Wrapper that handles token refresh

STATE_FILE="./auth-state.json"

# Try loading existing state
if [[ -f "$STATE_FILE" ]]; then
    agent-browser state load "$STATE_FILE"
    agent-browser open https://app.example.com/dashboard

    # Check if session is still valid
    URL=$(agent-browser get url)
    if [[ "$URL" == *"/login"* ]]; then
        echo "Session expired, re-authenticating..."
        # Perform fresh login
        agent-browser snapshot -i
        agent-browser fill @e1 "$USERNAME"
        agent-browser fill @e2 "$PASSWORD"
        agent-browser click @e3
        agent-browser wait --url "**/dashboard"
        agent-browser state save "$STATE_FILE"
    fi
else
    # First-time login
    agent-browser open https://app.example.com/login
    # ... login flow ...
fi
```

## Security Best Practices

1. **Never commit state files** - They contain session tokens
   ```bash
   echo "*.auth-state.json" >> .gitignore
   ```

2. **Use environment variables for credentials**
   ```bash
   agent-browser fill @e1 "$APP_USERNAME"
   agent-browser fill @e2 "$APP_PASSWORD"
   ```

3. **Clean up after automation**
   ```bash
   agent-browser cookies clear
   rm -f ./auth-state.json
   ```

4. **Use short-lived sessions for CI/CD**
   ```bash
   # Don't persist state in CI
   agent-browser open https://app.example.com/login
   # ... login and perform actions ...
   agent-browser close  # Session ends, nothing persisted
   ```
