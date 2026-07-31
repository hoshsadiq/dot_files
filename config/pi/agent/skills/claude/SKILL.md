---
name: claude
description: >
  Run Claude Code CLI for code analysis and automated edits. Use when users ask
  to run `claude -p`, continue or resume a Claude Code session, delegate a
  coding task to Claude, or get machine-readable output from Claude Code in the
  terminal.
license: MIT
metadata:
  author: Andy Pai
  version: "1.5"
---

# Claude Code CLI

Use this skill when you need the local `claude` CLI from a Codex-style harness.
Bias toward non-interactive `claude -p` runs. Treat the CLI as an automation
tool, not an interactive brainstorming partner, unless the user explicitly asks
to stay inside Claude.

## First Check

Confirm the CLI is healthy before you build a workflow around it:

```bash
claude --version
claude auth status --text
```

If either command fails, stop and report the setup or auth problem. Do not
retry task prompts until preflight works.

## Default Flows

Use exactly one prompt source per `claude -p` run:

- short prompt: pass it as the trailing argument
- long or multi-line prompt: pass it over stdin

Do not mix stdin with a trailing prompt argument. The CLI can merge both
inputs, which makes harness behavior unreliable.

### One-shot analysis

Default choice for summarization, critique, and read-only analysis:

```bash
claude -p \
  --model sonnet \
  --effort medium \
  --permission-mode plan \
  --no-session-persistence \
  "Summarize the uncommitted changes"
```

### One-shot edits

Use this when Claude should change files in the current repo:

```bash
claude -p \
  --model sonnet \
  --effort high \
  --permission-mode acceptEdits \
  --no-session-persistence \
  "Fix the failing tests in the current repo"
```

Narrow the working set first if the change is broad or the repo is noisy.

### Continue or resume

Use persisted sessions only when you expect to continue later.

- If you want a disposable one-shot run, keep `--no-session-persistence`.
- If you want to continue later, omit that flag.
- Prefer `-r <session-id> -p` when the exact session matters.
- Use `-c -p` only when reusing the latest local conversation is clearly safe.

```bash
printf '%s\n' "Continue and focus on the failing tests only" | claude -c -p
```

```bash
printf '%s\n' "Finish the refactor and summarize the remaining risks" | \
  claude -r <session-id> -p
```

### Structured output

Use JSON only when another tool will parse the result:

```bash
claude -p \
  --model sonnet \
  --effort medium \
  --permission-mode plan \
  --no-session-persistence \
  --output-format json \
  "Summarize the current diff"
```

`--output-format json` returns an envelope, not raw model text. The main body is
usually in `result`. Check `subtype` and `errors`, not only `is_error`.

## Review And Plan Critique

Use the same workflow for code review and implementation-plan critique. Start
broad once, then narrow scope if needed. Do not keep retrying with slightly
different wording.

### Broad attempt

Use repo-native review for ordinary local-change review:

```bash
claude -p \
  --model sonnet \
  --effort medium \
  --permission-mode plan \
  --no-session-persistence \
  "Review the current uncommitted changes in this repo. Focus on concrete bugs, regressions, misleading docs, packaging issues, and risky assumptions. Output sections in this exact order: Findings, Open questions, Residual risks. Findings should come first with file references. If there are no findings, say 'No findings'."
```

Use stdin-only prompts for longer plan critique requests:

```bash
claude -p \
  --model sonnet \
  --effort medium \
  --permission-mode plan \
  --no-session-persistence \
  < /tmp/claude_prompt.txt
```

### Narrowing ladder

If scope needs tightening, narrow in this order:

1. `git diff --staged` when the user clearly means staged work
2. `git diff --unified=3 -- <paths...>` when the worktree is noisy or large
3. one file or subsystem at a time if the narrowed diff is still too broad

Example narrowed diff review:

```bash
git diff --unified=3 -- path/to/file1 path/to/file2 | \
  claude -p \
    --model sonnet \
    --effort medium \
    --permission-mode plan \
    --no-session-persistence \
    "Review this diff only. Focus on concrete bugs, regressions, misleading docs, packaging issues, and risky assumptions. Output sections in this exact order: Findings, Open questions, Residual risks. Findings should come first with file references. If there are no findings, say 'No findings'."
```

Repo-native review can inspect unrelated worktree changes. Use staged or
file-scoped diffs when scope matters.

## Hard Rules

Treat every failed or suspicious run as one of these cases, then take the
single next action listed here.

### Preflight failure

`claude --version` or `claude auth status --text` fails.

Next action: stop and report the setup or auth problem.

### Non-zero exit

`claude -p` exits non-zero.

Next action: stop and report the exit reason or stderr. Do not rerun the same
shape.

### Slow but still running

The command is still running and has not failed.

Next action: wait once. If it remains too slow for the task, narrow scope.

### Empty stdout

The command exits cleanly but prints nothing useful.

Next action: inspect stderr, then rerun once in plain text with a smaller prompt.
If that also fails, stop and report it.

### JSON envelope issue

JSON mode returns an envelope but the useful payload is missing or unusable.

Next action: check `result`, `subtype`, and `errors`. If the envelope still does
not give a usable answer, rerun once with `--output-format text`.

### Scope too broad

Claude is slow, vague, or obviously reviewing the wrong surface.

Next action: switch to the narrowing ladder. Change scope, not wording.

### Tool or configuration limit

Claude reports a tool limit, configuration limit, or similar execution problem.

Next action: simplify the scope or prompt. Do not retry the same broad command
with slightly different phrasing.

### Retry budget

For review and plan critique:

- allow at most one broad attempt
- allow at most one narrowed attempt
- after that, stop and summarize what failed, what was tried, and the next
  safest narrower attempt

## Advanced Knobs

Keep the main workflow simple. Advanced flags drift more often and should be
verified against the local CLI help before first use in a new environment.

Read [references/claude-cli.md](references/claude-cli.md) only when you need:

- tool allow or deny lists
- system prompt control
- streaming output
- worktree mode
- settings overrides
- more detailed JSON behavior notes

## Update Check

On first use in a session, silently check:

1. `https://raw.githubusercontent.com/abpai/skills/main/versions.json`
2. Compare the remote `claude` version to this file's `metadata.version`
3. If remote is newer, pause before the task and ask whether to run:

```bash
npx skills update claude
```

If the fetch fails, skip the check silently.
