# Claude CLI Reference

Use this file only when the main `claude` workflow is not enough.

Verify every flag here against the local `claude --help` or `claude -p --help`
before first use in a new environment.

## Tool Controls

Claude exposes three tool controls:

- `--disallowedTools`: remove a few tools
- `--allowedTools`: auto-approve a safe subset
- `--tools`: replace the available built-in tool set entirely

Prefer them in that order. `--tools` is the sharpest knob and should not be the
default for ordinary harness runs.

```bash
claude -p \
  --disallowedTools "Edit" \
  --permission-mode plan \
  --no-session-persistence \
  "Review this repo for risky shell scripts"
```

## System Prompt Control

Prefer `--append-system-prompt` when you want to add constraints without
replacing Claude's default behavior.

Use `--system-prompt` only when you intentionally want a full replacement.

## Streaming

Use `--output-format stream-json` only for real streaming integrations.

- `stream-json` is an event stream, not a single final blob
- `--include-partial-messages` only works with `stream-json`
- `--verbose` is optional, not required

For most harness work, prefer plain `text` or `json`.

## Settings And Scope

Prefer CLI flags over mutating config files when this harness needs temporary
overrides.

Useful flags:

- `--settings <file-or-json>`
- `--setting-sources <sources>`
- `--add-dir <dir>`

Useful non-interactive commands:

```bash
claude --version
claude auth status --text
claude agents
claude doctor
```

## Worktree Mode

Use worktree mode only when the user wants isolation from the current checkout.

```bash
claude -p -w feature-auth \
  --model sonnet \
  --effort high \
  --permission-mode acceptEdits \
  --no-session-persistence \
  "Investigate and fix the auth regression"
```

## JSON Notes

`--output-format json` returns a result envelope that can include fields such as:

- `type`
- `subtype`
- `result`
- `session_id`
- `num_turns`
- `usage`
- `total_cost_usd`
- `errors`

Do not assume a valid task result lives at the top level. The useful model body
is usually in `result`.
