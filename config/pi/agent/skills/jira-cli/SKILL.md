---
name: jira-cli
description: Interact with Jira using jira-cli (https://github.com/ankitpokhrel/jira-cli). Use for listing issues, creating tickets, transitioning status, viewing details, managing sprints/epics, and any Jira-related operations.
---

# Jira CLI

Use `jira` command-line tool for all Jira interactions. This is the primary way to manage Jira issues on this machine.

## Prerequisites

- `jira` CLI must be installed (`brew install ankitpokhrel/jira-cli/jira`)
- `JIRA_API_TOKEN` environment variable must be set
- Run `jira init` if not configured

## Quick Reference

### Issue Operations

```bash
# List issues (interactive UI by default)
jira issue list

# List with filters
jira issue list -a$(jira me)                    # Assigned to me
jira issue list -s"In Progress"                 # By status
jira issue list -yHigh                          # By priority
jira issue list --created -7d                   # Created last 7 days
jira issue list -tBug                           # By type
jira issue list -lbackend                       # By label
jira issue list -pPROJECT                       # By project
jira issue list --plain                         # Plain text output
jira issue list --plain --no-headers            # For scripting

# View issue details
jira issue view ISSUE-123
jira issue view ISSUE-123 --comments 5          # With recent comments

# Create issue
jira issue create                               # Interactive
jira issue create -tTask -s"Summary" -b"Description" --no-input
jira issue create -tBug -s"Bug title" -yHigh -lurgent

# Edit issue
jira issue edit ISSUE-123
jira issue edit ISSUE-123 -s"New summary" --no-input
jira issue edit ISSUE-123 --label -old --label new  # Remove/add labels

# Transition/Move issue
jira issue move ISSUE-123 "In Progress"
jira issue move ISSUE-123 Done -RFixed          # With resolution

# Assign issue
jira issue assign ISSUE-123 $(jira me)          # To self
jira issue assign ISSUE-123 "John Doe"          # To user
jira issue assign ISSUE-123 x                   # Unassign

# Clone issue
jira issue clone ISSUE-123
jira issue clone ISSUE-123 -s"New summary"

# Delete issue
jira issue delete ISSUE-123
jira issue delete ISSUE-123 --cascade           # With subtasks

# Link issues
jira issue link ISSUE-1 ISSUE-2 Blocks

# Add comment
jira issue comment add ISSUE-123 "Comment text"

# Add worklog
jira issue worklog add ISSUE-123 "2h 30m" --no-input
```

### Sprint Operations

```bash
# List sprints
jira sprint list
jira sprint list --table                        # Table view
jira sprint list --current                      # Current sprint issues
jira sprint list --prev                         # Previous sprint
jira sprint list --next                         # Next sprint
jira sprint list SPRINT_ID                      # Specific sprint

# Add issues to sprint
jira sprint add SPRINT_ID ISSUE-1 ISSUE-2
```

### Epic Operations

```bash
# List epics
jira epic list
jira epic list --table
jira epic list EPIC-KEY                         # Issues in epic

# Create epic
jira epic create -n"Epic name" -s"Summary" -b"Description"

# Add/Remove issues from epic
jira epic add EPIC-KEY ISSUE-1 ISSUE-2
jira epic remove ISSUE-1 ISSUE-2
```

### Other Commands

```bash
# Get current user
jira me

# Open in browser
jira open                                       # Project
jira open ISSUE-123                             # Issue

# List projects
jira project list

# List boards
jira board list

# List releases
jira release list
```

## Common Workflows

### Find my open tasks
```bash
jira issue list -a$(jira me) -s~Done
```

### What did I work on this week?
```bash
jira issue list -a$(jira me) --updated -7d
```

### High priority bugs assigned to me
```bash
jira issue list -a$(jira me) -tBug -yHigh -sCritical
```

### Create and assign a task
```bash
jira issue create -tTask -s"Task summary" -b"Description" --no-input
jira issue assign ISSUE-123 $(jira me)
```

### Move issue through workflow
```bash
jira issue move ISSUE-123 "In Progress"
# ... do work ...
jira issue move ISSUE-123 "Code Review"
jira issue move ISSUE-123 Done -RFixed
```

## Output Formats

- **Default**: Interactive TUI with navigation (j/k/arrows, Enter to open, q to quit)
- **--plain**: Simple text output for scripting
- **--raw**: JSON output
- **--csv**: CSV output
- **--no-headers**: Omit headers (useful with --plain)

## JQL Queries

Use `-q` flag for custom JQL within project context:
```bash
jira issue list -q "summary ~ 'api' AND status = 'Open'"
jira issue list -q "assignee = currentUser() AND sprint in openSprints()"
```

## Tips

1. Use `$(jira me)` to reference yourself in commands
2. Use `~` prefix to negate: `-s~Done` means "status NOT Done"
3. Use `-x` for unassigned: `-ax` means "assignee is empty"
4. Combine filters: `-a$(jira me) -yHigh -s"To Do" --created month`
5. Use `--order-by rank --reverse` to match Jira board order