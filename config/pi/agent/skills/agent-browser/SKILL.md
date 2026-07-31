---
name: agent-browser
description: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task. Triggers include requests to "open a website", "fill out a form", "click a button", "take a screenshot", "scrape data from a page", "test this web app", "login to a site", "automate browser actions", or any task requiring programmatic web interaction.
allowed-tools:
  - Bash
  - Bash(agent-browser:*)
  - Bash(npx agent-browser:*)
metadata:
  version: "1.3"
  upstream_skill: https://github.com/vercel-labs/agent-browser/tree/main/skills/agent-browser
---

# Browser Automation with agent-browser

> **MANDATORY**: Always use the `agent-browser` CLI for browser automation — do NOT use MCP chrome-devtools tools. To reuse an existing Chrome session, prefer `agent-browser connect "${AGENT_BROWSER_CDP_PORT:-9222}"` so later commands stay attached to the same browser; use `--cdp <port>` or `--auto-connect` for one-off calls.

## Core Workflow

Every browser automation follows one of these patterns:

1. **Fresh browser**: `agent-browser open <url>` when the user wants a new ephemeral browser.
2. **Reuse existing Chrome (preferred for logged-in state and fewer browser instances)**:
   `agent-browser connect "${AGENT_BROWSER_CDP_PORT:-9222}"`
3. **Snapshot**: `agent-browser snapshot -i` (get element refs like `@e1`, `@e2`)
4. **Interact**: Use refs to click, fill, select
5. **Re-snapshot**: After navigation or DOM changes, get fresh refs

```bash
agent-browser connect "${AGENT_BROWSER_CDP_PORT:-9222}"
agent-browser open https://example.com/form
agent-browser get url
agent-browser snapshot -i
# Output: @e1 [input type="email"], @e2 [input type="password"], @e3 [button] "Submit"

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i  # Check result
```

### Open Confirmation (Required)

After every `open`, confirm the browser actually reached the target page before continuing:

```bash
agent-browser open <url>
agent-browser get url
agent-browser get title
```

If `get url` is still `about:blank`, the page closes immediately, or load does not stabilize, stop and report this to the user before taking more actions.

## Connecting to Existing Chrome

When the user wants to reuse an authenticated Chrome, extensions, or a browser already launched with remote debugging, attach once with `connect` and keep using plain `agent-browser` commands afterward. If the environment already sets `AGENT_BROWSER_CDP_PORT`, do not assume the CLI reads it automatically; pass it explicitly:

```bash
agent-browser connect "${AGENT_BROWSER_CDP_PORT:-9222}"
agent-browser open https://example.com
agent-browser snapshot -i
```

For one-off commands, or when attaching to a remote WebSocket endpoint, pass `--cdp` directly:

```bash
agent-browser --cdp "${AGENT_BROWSER_CDP_PORT:-9222}" snapshot -i
agent-browser --cdp "wss://your-browser-service.com/cdp?token=..." snapshot -i
```

Use `--auto-connect` when Chrome is already exposing remote debugging but the port is dynamic or unknown:

```bash
agent-browser --auto-connect open https://example.com
agent-browser --auto-connect snapshot -i
```

### Launching Chrome for Debugging

If Chrome isn't running with remote debugging, launch it first:

```bash
# macOS — detached launch (survives command-runner cleanup)
open -na "Google Chrome" --args \
  --remote-debugging-port="${AGENT_BROWSER_CDP_PORT:-9222}" \
  --user-data-dir="$HOME/Projects/ai-chrome-profile"
sleep 3

agent-browser connect "${AGENT_BROWSER_CDP_PORT:-9222}"
agent-browser open https://example.com
```

### Fallback

If `connect`, `--auto-connect`, or `--cdp` fails, do **not** silently switch. Ask the user:

- `headed fresh session`: `agent-browser --headed open <url>`
- `headless fresh session`: `agent-browser open <url>`

### Clean Session

When the user asks for a "clean", "fresh", or "incognito" session, avoid `connect`, `--auto-connect`, `--cdp`, and any persisted browser state from config or env (`--profile`, `--session-name`, saved session names):

```bash
tmp_config="$(mktemp -t agent-browser-clean)"
printf '{}\n' > "$tmp_config"

env -u AGENT_BROWSER_PROFILE \
  -u AGENT_BROWSER_SESSION_NAME \
  -u AGENT_BROWSER_SESSION \
  -u AGENT_BROWSER_STATE \
  -u AGENT_BROWSER_CDP_PORT \
  -u AGENT_BROWSER_AUTO_CONNECT \
  AGENT_BROWSER_CONFIG="$tmp_config" \
  agent-browser open <url>
```

Do not proactively run `agent-browser close` here. In a CDP reuse workflow, that can close the user's existing Chrome session instead of just isolating the next run.

If the user wants the clean browser visible, add `--headed` to the final command.

## Handling Authentication

Five approaches, from simplest to most secure:

1. **Import from browser** — launch Chrome with `--remote-debugging-port`, grab auth state, reuse
2. **Persistent profile** — `--profile ./browser-data` keeps a Chrome user-data directory
3. **Session name** — `--session-name myapp` auto-saves/restores cookies and storage
4. **Auth vault** — encrypted credential store; LLM never sees passwords
5. **State file** — `state save` / `state load` for manual snapshot of cookies + storage

See [Common Patterns](#common-patterns) below for detailed examples of Auth Vault and State Persistence workflows, and [references/authentication.md](references/authentication.md) for the full guide.

## Command Chaining

Commands can be chained with `&&` in a single shell invocation. The browser persists between commands via a background daemon, so chaining is safe and more efficient than separate calls.

```bash
# Chain open + wait + snapshot in one call
agent-browser open https://example.com && agent-browser wait --load networkidle && agent-browser snapshot -i

# Chain multiple interactions
agent-browser fill @e1 "user@example.com" && agent-browser fill @e2 "password123" && agent-browser click @e3

# Navigate and capture
agent-browser open https://example.com && agent-browser wait --load networkidle && agent-browser screenshot page.png
```

**When to chain:** Use `&&` when you don't need to read the output of an intermediate command before proceeding (e.g., open + wait + screenshot). Run commands separately when you need to parse the output first (e.g., snapshot to discover refs, then interact using those refs).

### Network Inspection and Dialogs

When debugging flaky pages or testing browser-side behavior, inspect requests or handle dialogs explicitly instead of guessing what happened:

```bash
# Inspect or filter captured requests
agent-browser network requests
agent-browser network requests --filter api

# Mock or block a specific request pattern
agent-browser network route "**/api/*" --abort
agent-browser network route "**/data.json" --body '{"mock": true}'

# Handle alert/confirm/prompt dialogs
agent-browser dialog accept
agent-browser dialog accept "typed into prompt"
agent-browser dialog dismiss
```

See [references/commands.md](references/commands.md) for the full command surface.

## Essential Commands

```bash
# Navigation
agent-browser connect <port|ws-url>   # Attach the daemon to an existing Chrome via CDP
agent-browser open <url>              # Navigate (aliases: goto, navigate)
agent-browser close                   # Close browser

# Snapshot
agent-browser snapshot -i             # Interactive elements with refs (recommended)
agent-browser snapshot -i -C          # Include cursor-interactive elements (divs with onclick, cursor:pointer)
agent-browser snapshot -s "#selector" # Scope to CSS selector

# Interaction (use @refs from snapshot)
agent-browser click @e1               # Click element
agent-browser click @e1 --new-tab     # Click and open in new tab
agent-browser fill @e2 "text"         # Clear and type text
agent-browser type @e2 "text"         # Type without clearing
agent-browser select @e1 "option"     # Select dropdown option
agent-browser check @e1               # Check checkbox
agent-browser press Enter             # Press key
agent-browser keyboard type "text"    # Type at current focus (no selector)
agent-browser keyboard inserttext "text"  # Insert without key events
agent-browser scroll down 500         # Scroll page
agent-browser scroll down 500 --selector "div.content"  # Scroll within a specific container

# Get information
agent-browser get text @e1            # Get element text
agent-browser get url                 # Get current URL
agent-browser get title               # Get page title
agent-browser get cdp-url             # Get CDP WebSocket URL

# Wait
agent-browser wait @e1                # Wait for element
agent-browser wait --load networkidle # Wait for network idle
agent-browser wait --url "**/page"    # Wait for URL pattern
agent-browser wait --text "Welcome"   # Wait for text to appear
agent-browser wait --fn "!document.body.innerText.includes('Loading...')"  # Wait for JS condition
agent-browser wait "#spinner" --state hidden  # Wait for element to disappear
agent-browser wait 2000               # Wait milliseconds

# Downloads
agent-browser download @e1 ./file.pdf          # Click element to trigger download
agent-browser wait --download ./output.zip     # Wait for any download to complete
agent-browser --download-path ./downloads open <url>  # Set default download directory

# Capture
agent-browser screenshot              # Screenshot to temp dir
agent-browser screenshot --full       # Full page screenshot
agent-browser screenshot --annotate   # Annotated screenshot with numbered element labels
agent-browser screenshot --screenshot-dir ./shots           # Save to specific directory
agent-browser screenshot --screenshot-format jpeg --screenshot-quality 80  # Format and quality
agent-browser pdf output.pdf          # Save as PDF

# Clipboard
agent-browser clipboard read          # Read clipboard contents
agent-browser clipboard write "Hello, World!"  # Write to clipboard
agent-browser clipboard copy          # Copy current selection
agent-browser clipboard paste         # Paste clipboard contents

# Diff (compare page states)
agent-browser diff snapshot                          # Compare current vs last snapshot
agent-browser diff snapshot --baseline before.txt    # Compare current vs saved file
agent-browser diff screenshot --baseline before.png  # Visual pixel diff
agent-browser diff url <url1> <url2>                 # Compare two pages
agent-browser diff url <url1> <url2> --wait-until networkidle  # Custom wait strategy
agent-browser diff url <url1> <url2> --selector "#main"  # Scope to element
```

## Common Patterns

### Form Submission

```bash
agent-browser open https://example.com/signup
agent-browser snapshot -i
agent-browser fill @e1 "Jane Doe"
agent-browser fill @e2 "jane@example.com"
agent-browser select @e3 "California"
agent-browser check @e4
agent-browser click @e5
agent-browser wait --load networkidle
```

### Authentication with Auth Vault (Recommended)

```bash
# Save credentials once (encrypted with AGENT_BROWSER_ENCRYPTION_KEY)
# Recommended: pipe password via stdin to avoid shell history exposure
echo "pass" | agent-browser auth save github --url https://github.com/login --username user --password-stdin

# Login using saved profile (LLM never sees password)
agent-browser auth login github

# List/show/delete profiles
agent-browser auth list
agent-browser auth show github
agent-browser auth delete github
```

### Authentication with State Persistence

```bash
# Login once and save state
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "$USERNAME"
agent-browser fill @e2 "$PASSWORD"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser state save auth.json

# Reuse in future sessions
agent-browser state load auth.json
agent-browser open https://app.example.com/dashboard
```

### Session Persistence

```bash
# Auto-save/restore cookies and localStorage across browser restarts
agent-browser --session-name myapp open https://app.example.com/login
# ... login flow ...
agent-browser close  # State auto-saved to ~/.agent-browser/sessions/

# Next time, state is auto-loaded
agent-browser --session-name myapp open https://app.example.com/dashboard

# Encrypt state at rest
export AGENT_BROWSER_ENCRYPTION_KEY=$(openssl rand -hex 32)
agent-browser --session-name secure open https://app.example.com

# Manage saved states
agent-browser state list
agent-browser state show myapp-default.json
agent-browser state clear myapp
agent-browser state clean --older-than 7
```

### Data Extraction

```bash
agent-browser open https://example.com/products
agent-browser snapshot -i
agent-browser get text @e5           # Get specific element text
agent-browser get text body > page.txt  # Get all page text

# JSON output for parsing
agent-browser snapshot -i --json
agent-browser get text @e1 --json
```

### Parallel Sessions

```bash
agent-browser --session site1 open https://site-a.com
agent-browser --session site2 open https://site-b.com

agent-browser --session site1 snapshot -i
agent-browser --session site2 snapshot -i

agent-browser session list
```

### Color Scheme (Dark Mode)

```bash
# Persistent dark mode via flag (applies to all pages and new tabs)
agent-browser --color-scheme dark open https://example.com

# Or via environment variable
AGENT_BROWSER_COLOR_SCHEME=dark agent-browser open https://example.com

# Or set during session (persists for subsequent commands)
agent-browser set media dark
```

### Viewport & Responsive Testing

```bash
# Set viewport size
agent-browser set viewport 1920 1080

# Mobile viewport
agent-browser set viewport 375 812

# Retina / HiDPI — third parameter is the device scale factor
# (e.g., 2 for Retina, 3 for iPhone Plus)
agent-browser set viewport 1920 1080 2

# Device emulation (viewport + user-agent + touch)
agent-browser set device "iPhone 14"
agent-browser set device "Pixel 7"
```

The `scale` parameter (device pixel ratio) controls how many physical pixels map to each CSS pixel. Use `2` for standard Retina displays, `3` for high-density mobile screens. This affects screenshot resolution and media queries like `(-webkit-min-device-pixel-ratio: 2)`.

### Visual Browser (Debugging)

```bash
agent-browser --headed open https://example.com
agent-browser highlight @e1          # Highlight element
agent-browser inspect                # Open DevTools inspector
agent-browser record start demo.webm # Record session
agent-browser profiler start         # Start Chrome DevTools profiling
agent-browser profiler stop trace.json # Stop and save profile (path optional)
```

You can also enable headed mode via environment variable: `AGENT_BROWSER_HEADED=1 agent-browser open https://example.com`

### Local Files (PDFs, HTML)

```bash
# Open local files with file:// URLs
agent-browser --allow-file-access open file:///path/to/document.pdf
agent-browser --allow-file-access open file:///path/to/page.html
agent-browser screenshot output.png
```

### iOS Simulator (Mobile Safari)

```bash
# List available iOS simulators
agent-browser device list

# Launch Safari on a specific device
agent-browser -p ios --device "iPhone 16 Pro" open https://example.com

# Same workflow as desktop - snapshot, interact, re-snapshot
agent-browser -p ios snapshot -i
agent-browser -p ios tap @e1          # Tap (alias for click)
agent-browser -p ios fill @e2 "text"
agent-browser -p ios swipe up         # Mobile-specific gesture

# Take screenshot
agent-browser -p ios screenshot mobile.png

# Close session (shuts down simulator)
agent-browser -p ios close
```

**Requirements:** macOS with Xcode, Appium (`npm install -g appium && appium driver install xcuitest`)

**Real devices:** Works with physical iOS devices if pre-configured. Use `--device "<UDID>"` where UDID is from `xcrun xctrace list devices`.

## Security

All security features are opt-in. By default, agent-browser imposes no restrictions on navigation, actions, or output.

### Content Boundaries (Recommended for AI Agents)

Enable `--content-boundaries` to wrap page-sourced output in markers that help LLMs distinguish tool output from untrusted page content:

```bash
export AGENT_BROWSER_CONTENT_BOUNDARIES=1
agent-browser snapshot
# Output:
# --- AGENT_BROWSER_PAGE_CONTENT nonce=<hex> origin=https://example.com ---
# [accessibility tree]
# --- END_AGENT_BROWSER_PAGE_CONTENT nonce=<hex> ---
```

### Domain Allowlist

Restrict navigation to trusted domains. Wildcards like `*.example.com` also match the bare domain `example.com`. Sub-resource requests, WebSocket, and EventSource connections to non-allowed domains are also blocked. Include CDN domains your target pages depend on:

```bash
export AGENT_BROWSER_ALLOWED_DOMAINS="example.com,*.example.com"
agent-browser open https://example.com        # OK
agent-browser open https://malicious.com       # Blocked
```

### Action Policy

Use a policy file to gate destructive actions:

```bash
export AGENT_BROWSER_ACTION_POLICY=./policy.json
```

Example `policy.json`:
```json
{"default": "deny", "allow": ["navigate", "snapshot", "click", "scroll", "wait", "get"]}
```

Auth vault operations (`auth login`, etc.) bypass action policy but domain allowlist still applies.

### Confirmation Policy

If you want the browser to require explicit approval for risky actions, use confirmation controls in addition to action policies:

```bash
export AGENT_BROWSER_CONFIRM_ACTIONS="download,upload,navigate"
export AGENT_BROWSER_CONFIRM_INTERACTIVE=1
```

In non-interactive environments, avoid relying on interactive confirmation prompts alone; pair them with action policy or domain restrictions.

### Output Limits

Prevent context flooding from large pages:

```bash
export AGENT_BROWSER_MAX_OUTPUT=50000
```

## Diffing (Verifying Changes)

Use `diff snapshot` after performing an action to verify it had the intended effect. This compares the current accessibility tree against the last snapshot taken in the session.

```bash
# Typical workflow: snapshot -> action -> diff
agent-browser snapshot -i          # Take baseline snapshot
agent-browser click @e2            # Perform action
agent-browser diff snapshot        # See what changed (auto-compares to last snapshot)
```

For visual regression testing or monitoring:

```bash
# Save a baseline screenshot, then compare later
agent-browser screenshot baseline.png
# ... time passes or changes are made ...
agent-browser diff screenshot --baseline baseline.png

# Compare staging vs production
agent-browser diff url https://staging.example.com https://prod.example.com --screenshot
```

`diff snapshot` output uses `+` for additions and `-` for removals, similar to git diff. `diff screenshot` produces a diff image with changed pixels highlighted in red, plus a mismatch percentage.

## Timeouts and Slow Pages

The default timeout is 25 seconds for local browsers. This can be overridden with the `AGENT_BROWSER_DEFAULT_TIMEOUT` environment variable (value in milliseconds). For slow websites or large pages, use explicit waits instead of relying on the default timeout:

```bash
# Wait for network activity to settle (best for slow pages)
agent-browser wait --load networkidle

# Wait for a specific element to appear
agent-browser wait "#content"
agent-browser wait @e1

# Wait for a specific URL pattern (useful after redirects)
agent-browser wait --url "**/dashboard"

# Wait for a JavaScript condition
agent-browser wait --fn "document.readyState === 'complete'"

# Wait a fixed duration (milliseconds) as a last resort
agent-browser wait 5000
```

When dealing with consistently slow websites, use `wait --load networkidle` after `open` to ensure the page is fully loaded before taking a snapshot. If a specific element is slow to render, wait for it directly with `wait <selector>` or `wait @ref`.

## Session Management and Cleanup

When running multiple agents or automations concurrently, always use named sessions to avoid conflicts:

```bash
# Each agent gets its own isolated session
agent-browser --session agent1 open site-a.com
agent-browser --session agent2 open site-b.com

# Check active sessions
agent-browser session list
```

Set an idle timeout so the daemon auto-shuts down when inactive:

```bash
AGENT_BROWSER_IDLE_TIMEOUT_MS=60000 agent-browser open example.com
```

Always close your browser session when done to avoid leaked processes:

```bash
agent-browser close                    # Close default session
agent-browser --session agent1 close   # Close specific session
```

If a previous session was not closed properly, the daemon may still be running. Use `agent-browser close` to clean it up before starting new work.

## Ref Lifecycle (Important)

Refs (`@e1`, `@e2`, etc.) are invalidated when the page changes. Always re-snapshot after:

- Clicking links or buttons that navigate
- Form submissions
- Dynamic content loading (dropdowns, modals)

```bash
agent-browser click @e5              # Navigates to new page
agent-browser snapshot -i            # MUST re-snapshot
agent-browser click @e1              # Use new refs
```

## Annotated Screenshots (Vision Mode)

Use `--annotate` to take a screenshot with numbered labels overlaid on interactive elements. Each label `[N]` maps to ref `@eN`. This also caches refs, so you can interact with elements immediately without a separate snapshot.

```bash
agent-browser screenshot --annotate
# Output includes the image path and a legend:
#   [1] @e1 button "Submit"
#   [2] @e2 link "Home"
#   [3] @e3 textbox "Email"
agent-browser click @e2              # Click using ref from annotated screenshot
```

Use annotated screenshots when:
- The page has unlabeled icon buttons or visual-only elements
- You need to verify visual layout or styling
- Canvas or chart elements are present (invisible to text snapshots)
- You need spatial reasoning about element positions

## Semantic Locators (Alternative to Refs)

When refs are unavailable or unreliable, use semantic locators:

```bash
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find role button click --name "Submit"
agent-browser find placeholder "Search" type "query"
agent-browser find testid "submit-btn" click
```

## JavaScript Evaluation (eval)

Use `eval` to run JavaScript in the browser context. **Shell quoting can corrupt complex expressions** -- use `--stdin` or `-b` to avoid issues.

```bash
# Simple expressions work with regular quoting
agent-browser eval 'document.title'
agent-browser eval 'document.querySelectorAll("img").length'

# Complex JS: use --stdin with heredoc (RECOMMENDED)
agent-browser eval --stdin <<'EVALEOF'
JSON.stringify(
  Array.from(document.querySelectorAll("img"))
    .filter(i => !i.alt)
    .map(i => ({ src: i.src.split("/").pop(), width: i.width }))
)
EVALEOF

# Alternative: base64 encoding (avoids all shell escaping issues)
agent-browser eval -b "$(echo -n 'Array.from(document.querySelectorAll("a")).map(a => a.href)' | base64)"
```

**Why this matters:** When the shell processes your command, inner double quotes, `!` characters (history expansion), backticks, and `$()` can all corrupt the JavaScript before it reaches agent-browser. The `--stdin` and `-b` flags bypass shell interpretation entirely.

**Rules of thumb:**
- Single-line, no nested quotes -> regular `eval 'expression'` with single quotes is fine
- Nested quotes, arrow functions, template literals, or multiline -> use `eval --stdin <<'EVALEOF'`
- Programmatic/generated scripts -> use `eval -b` with base64

## Configuration File

Create `agent-browser.json` in the project root for persistent settings:

```json
{
  "headed": true,
  "proxy": "http://localhost:8080",
  "profile": "./browser-data"
}
```

Priority (lowest to highest): `~/.agent-browser/config.json` < `./agent-browser.json` < env vars < CLI flags. Use `--config <path>` or `AGENT_BROWSER_CONFIG` env var for a custom config file (exits with error if missing/invalid). All CLI options map to camelCase keys (e.g., `--executable-path` -> `"executablePath"`). Boolean flags accept `true`/`false` values (e.g., `--headed false` overrides config). Extensions from user and project configs are merged, not replaced.

## Browser Engine Selection

By default agent-browser uses Chromium via Playwright. You can switch to the experimental native Rust daemon with `--native`, or use [Lightpanda](https://lightpanda.io), which also implies native mode:

```bash
# Native daemon with the default Chrome engine
agent-browser --native open https://example.com
AGENT_BROWSER_NATIVE=1 agent-browser open https://example.com

# Via flag
agent-browser --engine lightpanda open https://example.com

# Via environment variable
AGENT_BROWSER_ENGINE=lightpanda agent-browser open https://example.com
```

**Native caveat:** Treat `--native` as experimental and verify behavior on unusual pages before relying on it for critical flows.

**Lightpanda limitations:** No extensions, no persistent profiles/state files, and no `file://` local file access. It is best for fast text extraction and snapshot-based workflows.

## Deep-Dive Documentation

| Reference | When to Use |
|-----------|-------------|
| [references/commands.md](references/commands.md) | Full command reference with all options |
| [references/snapshot-refs.md](references/snapshot-refs.md) | Ref lifecycle, invalidation rules, troubleshooting |
| [references/session-management.md](references/session-management.md) | Parallel sessions, state persistence, concurrent scraping |
| [references/authentication.md](references/authentication.md) | Login flows, OAuth, 2FA handling, state reuse |
| [references/video-recording.md](references/video-recording.md) | Recording workflows for debugging and documentation |
| [references/profiling.md](references/profiling.md) | Chrome DevTools profiling for performance analysis |
| [references/proxy-support.md](references/proxy-support.md) | Proxy configuration, geo-testing, rotating proxies |

## Ready-to-Use Templates

| Template | Description |
|----------|-------------|
| [templates/form-automation.sh](templates/form-automation.sh) | Form filling with validation |
| [templates/authenticated-session.sh](templates/authenticated-session.sh) | Login once, reuse state |
| [templates/capture-workflow.sh](templates/capture-workflow.sh) | Content extraction with screenshots |

```bash
./templates/form-automation.sh https://example.com/form
./templates/authenticated-session.sh https://app.example.com/login
./templates/capture-workflow.sh https://example.com ./output
```

## Update Check

On first use in a session, silently check for a newer version:

1. Fetch `https://raw.githubusercontent.com/abpai/skills/main/versions.json`.
2. Compare the version for `agent-browser` against this file's `metadata.version`.
3. If the remote version is newer, pause before the main task and ask:
   > **agent-browser** update available (local {X.Y} → remote {A.B}).
   > Would you like me to update it for you first?
   > I can run `npx skills update agent-browser` for you.
4. If the user says yes, run the update before continuing.
5. If the user says no, continue with the current local version.
6. If the fetch fails or web access is unavailable, skip silently.
