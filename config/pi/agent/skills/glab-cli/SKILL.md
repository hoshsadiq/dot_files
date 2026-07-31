---
name: glab-cli
description: Interact with GitLab using glab CLI (https://gitlab.com/gitlab-org/cli). Use for merge requests, issues, pipelines, releases, snippets, and any GitLab-related operations.
---

# GitLab CLI

Use `glab` command-line tool for all GitLab interactions. This is the primary way to manage GitLab resources on this machine.

## Prerequisites

- `glab` CLI must be installed (`brew install glab`)
- Run `glab auth login` to authenticate with GitLab
- Optionally set `GITLAB_TOKEN` environment variable

## Quick Reference

### Authentication

```bash
# Login interactively
glab auth login

# Login with token
glab auth login --token <token>

# Login to self-hosted instance
glab auth login --hostname gitlab.example.com

# Check auth status
glab auth status

# Logout
glab auth logout
```

### Merge Request Operations

```bash
# List MRs
glab mr list                                # Open MRs in current repo
glab mr list --all                          # All MRs
glab mr list --closed                       # Closed MRs
glab mr list --merged                       # Merged MRs
glab mr list --draft                        # Draft MRs
glab mr list --assignee @me                 # Assigned to me
glab mr list --author @me                   # Created by me
glab mr list --reviewer @me                 # Awaiting my review
glab mr list --label "bug"                  # By label
glab mr list --search "query"               # Text search
glab mr list --source-branch=feature        # By source branch

# View MR
glab mr view 123                            # By number
glab mr view branch-name                    # By branch
glab mr view 123 --web                      # Open in browser
glab mr view 123 --comments                 # With comments

# Create MR
glab mr create                              # Interactive
glab mr create --fill                       # Auto-fill from commits
glab mr create --draft                      # Create as draft
glab mr create --title "Title" --description "Body"
glab mr create --target-branch main         # Target branch
glab mr create --source-branch feature      # Source branch
glab mr create --label "bug,urgent"         # With labels
glab mr create --assignee @me               # Assign to self
glab mr create --reviewer user1             # Add reviewer
glab mr create --web                        # In browser

# Create MR for an issue
glab mr for 123                             # Create MR linked to issue

# Checkout MR
glab mr checkout 123                        # By number
glab mr checkout branch-name                # By branch

# Review MR
glab mr approve 123                         # Approve
glab mr revoke 123                          # Revoke approval
glab mr approvers 123                       # List eligible approvers
glab mr diff 123                            # View diff

# Merge MR
glab mr merge 123                           # Merge
glab mr merge 123 --squash                  # Squash and merge
glab mr merge 123 --rebase                  # Rebase before merge
glab mr merge 123 --remove-source-branch    # Delete branch after
glab mr merge 123 --when-pipeline-succeeds  # Auto-merge when CI passes

# Rebase MR
glab mr rebase 123                          # Rebase against target

# Other MR operations
glab mr close 123                           # Close MR
glab mr reopen 123                          # Reopen MR
glab mr update 123 --title "New title"      # Update MR
glab mr update 123 --draft                  # Convert to draft
glab mr update 123 --ready                  # Mark ready
glab mr note 123 -m "Comment text"          # Add comment
glab mr subscribe 123                       # Subscribe
glab mr unsubscribe 123                     # Unsubscribe
glab mr todo 123                            # Add to your to-do list
glab mr issues 123                          # Related issues
glab mr delete 123                          # Delete MR
```

### Issue Operations

```bash
# List issues
glab issue list                             # Open issues
glab issue list --all                       # All issues
glab issue list --closed                    # Closed issues
glab issue list --assignee @me              # Assigned to me
glab issue list --author @me                # Created by me
glab issue list --label "bug"               # By label
glab issue list --milestone "v1.0"          # By milestone
glab issue list --search "query"            # Text search

# View issue
glab issue view 123                         # By number
glab issue view 123 --web                   # Open in browser
glab issue view 123 --comments              # With comments

# Create issue
glab issue create                           # Interactive
glab issue create --title "Title" --description "Body"
glab issue create --label "bug,urgent"
glab issue create --assignee @me
glab issue create --milestone "v1.0"
glab issue create --confidential            # Confidential issue
glab issue create --web                     # In browser

# Edit issue
glab issue update 123 --title "New title"
glab issue update 123 --description "New body"
glab issue update 123 --label "bug"
glab issue update 123 --assignee user
glab issue update 123 --milestone "v1.0"
glab issue update 123 --confidential

# Close/Reopen
glab issue close 123
glab issue reopen 123

# Other
glab issue note 123 -m "Comment text"       # Add comment
glab issue subscribe 123                    # Subscribe
glab issue unsubscribe 123                  # Unsubscribe
glab issue delete 123                       # Delete issue
glab issue board list                       # List issue boards
glab issue board view BOARD_ID              # View board
```

### CI/CD Pipeline Operations

```bash
# List pipelines
glab ci list                                # Recent pipelines
glab ci list --status running               # By status
glab ci list --status failed

# View pipeline
glab ci view                                # Interactive TUI
glab ci view branch-name                    # For specific branch
glab ci get                                 # JSON of current pipeline
glab ci status                              # Current branch pipeline status

# Run pipeline
glab ci run                                 # Trigger pipeline on current branch
glab ci run -b main                         # On specific branch
glab ci run --variables "KEY:value"         # With variables
glab ci run-trig --token TOKEN              # Using trigger token

# Job operations
glab ci trace                               # Trace job log in real time
glab ci trace JOB_ID                        # Trace specific job
glab ci retry JOB_ID                        # Retry a job
glab ci trigger JOB_ID                      # Trigger manual job
glab ci artifact REF JOB_NAME               # Download artifacts

# Cancel
glab ci cancel                              # Cancel current pipeline
glab ci cancel PIPELINE_ID                  # Cancel specific pipeline

# Lint
glab ci lint                                # Validate .gitlab-ci.yml
glab ci lint .gitlab-ci.yml                 # Lint specific file

# Delete
glab ci delete PIPELINE_ID                  # Delete pipeline
```

### Repository Operations

```bash
# Clone
glab repo clone owner/repo                  # Clone repo
glab repo clone owner/repo -- --depth 1     # Shallow clone
glab repo clone -g group-name              # Clone all repos in group

# Create
glab repo create my-repo                    # Interactive
glab repo create my-repo --public
glab repo create my-repo --private
glab repo create my-repo --internal

# Fork
glab repo fork                              # Fork current repo
glab repo fork owner/repo                   # Fork specific repo
glab repo fork --clone                      # Clone after forking
glab repo fork --remote                     # Add remote

# View
glab repo view                              # Current repo
glab repo view owner/repo                   # Specific repo
glab repo view --web                        # Open in browser

# List
glab repo list                              # Your repos
glab repo list --member                     # Repos you're a member of

# Search
glab repo search --search "query"           # Search repositories

# Other
glab repo contributors                      # List contributors
glab repo members list                      # List project members
glab repo archive                           # Download repo archive
glab repo delete my-repo --yes              # Delete repo
glab repo transfer my-repo --target-namespace new-group
glab repo update --visibility public        # Update settings
glab repo mirror URL                        # Mirror repo
```

### Release Operations

```bash
# List releases
glab release list

# View release
glab release view v1.0.0                    # Specific version
glab release view v1.0.0 --web              # Open in browser

# Create release
glab release create v1.0.0                  # Interactive
glab release create v1.0.0 --name "v1.0"
glab release create v1.0.0 --notes "Release notes"
glab release create v1.0.0 --ref main       # From specific ref
glab release create v1.0.0 ./dist/*         # With assets

# Upload assets
glab release upload v1.0.0 ./file.tar.gz

# Download assets
glab release download v1.0.0
glab release download v1.0.0 --asset-name "*.tar.gz"

# Delete release
glab release delete v1.0.0 --yes
```

### Snippet Operations

```bash
# Create snippet
glab snippet create -t "Title" file.txt             # From file
glab snippet create -t "Title" file1.txt file2.txt   # Multiple files
glab snippet create -t "Title" -f "main.go"          # Read from stdin
```

### Label Operations

```bash
# List labels
glab label list

# Create label
glab label create --name "bug" --color "#FF0000"

# Edit label
glab label edit --name "bug" --new-name "defect"

# Get label
glab label get LABEL_ID

# Delete label
glab label delete --name "bug"
```

### Variable Operations

```bash
# List variables
glab variable list
glab variable list --group GROUP_ID         # Group variables

# Get variable
glab variable get MY_VAR

# Set variable
glab variable set MY_VAR "value"
glab variable set MY_VAR "value" --masked
glab variable set MY_VAR "value" --protected
glab variable set MY_VAR "value" --scope production

# Update variable
glab variable update MY_VAR "new-value"

# Export variables
glab variable export

# Delete variable
glab variable delete MY_VAR
```

### API Operations

```bash
# Make API calls
glab api /projects                          # GET request
glab api /projects/:id/issues               # List issues via API
glab api -X POST /projects/:id/issues -f title="Title" -f description="Body"
glab api /projects/:id --paginate           # Handle pagination

# Output formatting
glab api /user --jq '.username'
```

### Other Useful Commands

```bash
# Open in browser (via repo view)
glab repo view --web                        # Repo
glab issue view 123 --web                   # Issue
glab mr view 123 --web                      # MR

# Config
glab config set editor vim
glab config set git_protocol ssh
glab config list

# Incidents
glab incident list                          # List incidents
glab incident view 123                      # View incident

# Milestones
glab milestone list                         # List milestones
glab milestone create --title "v1.0"        # Create milestone

# Schedules
glab schedule list                          # List pipeline schedules
glab schedule run SCHEDULE_ID               # Run schedule

# SSH/GPG Keys
glab ssh-key list                           # List SSH keys
glab ssh-key add --title "My Key" < key.pub
glab gpg-key list                           # List GPG keys

# Deploy Keys
glab deploy-key list                        # List deploy keys

# Iterations
glab iteration list                         # List iterations

# Check for updates
glab check-update

# Version
glab version
```

## Common Workflows

### Create MR from current branch
```bash
git push -u origin HEAD
glab mr create --fill
```

#### Posting Inline DiffNote Comments

To anchor a comment to a specific line in the diff (a `DiffNote`), you **must** use a JSON body with the `Content-Type: application/json` header. Using `-F` form fields will create an unanchored `DiscussionNote`.

```bash
# Get SHA values from the MR
glab mr view <id> --output=json | grep -oP '"(base_sha|head_sha|start_sha)":\s*"\K[0-9a-f]{40}'

# Post a DiffNote on a new line
glab api --method POST "projects/:id/merge_requests/:iid/discussions" \
  -H "Content-Type: application/json" \
  --input - <<'JSONEOF'
{
  "body": "Your review comment here",
  "position": {
    "base_sha": "<base_sha>",
    "start_sha": "<start_sha>",
    "head_sha": "<head_sha>",
    "position_type": "text",
    "new_path": "path/to/file.js",
    "new_line": 42
  }
}
JSONEOF
```

**Key rules for DiffNotes:**
- Always use `--input -` with a heredoc and `-H "Content-Type: application/json"`. Never use `-F` for the `position` object — it will silently create a `DiscussionNote` instead.
- Line numbers are **new file line numbers** calculated from the diff hunk headers (`@@ -old,count +new,count @@`), not the diff output line numbers. Count only context lines and `+` lines from the hunk start.
- Verify findings on the **MR source branch** (`git fetch origin <branch>` then `git grep`), not the current working branch.
- To update an existing note: `glab api --method PUT "projects/:id/merge_requests/:iid/notes/:note_id" -H "Content-Type: application/json" --input - <<< '{"body":"updated text"}'`
- GitLab has no batch "Submit Review" API like GitHub. Post DiffNotes individually.
- To find a discussion or note ID: `glab api "projects/:id/merge_requests/:iid/discussions" --paginate`

### Review and merge MR
```bash
glab mr checkout 123
# ... review code ...
glab mr approve 123
glab mr merge 123 --squash --remove-source-branch
```

### Create issue and MR
```bash
glab issue create --title "Bug fix" --label "bug"
glab mr for 123                             # Create MR linked to issue
```

### Watch CI and auto-merge
```bash
glab mr merge --when-pipeline-succeeds --squash
glab ci view                                # Watch pipeline
```

### Quick release
```bash
glab release create v1.0.0 --notes "Release notes" ./dist/*
```

### Validate CI config
```bash
glab ci lint
```

## Output Formats

- **Default**: Colorized terminal output
- **--json**: JSON output with specific fields (on supported commands)
- **--jq**: Process JSON with jq expressions
- **--web / -w**: Open in browser

## MR Description Generation

**Template:** `assets/mr_description_template.md`

Generate MR descriptions by analyzing git diff between current branch and target:
- **Description** (1-2 sentences): Problem/feature addressed
- **Changes Made** (bullets): High-level architectural changes by layer
- **Additional Notes**: Profile activation, dependencies, test coverage, impacted modules, breaking changes

### Layer Categorization
When analyzing git diffs, group changes by layer:
- **API layer**: Changes in `api/` or gRPC implementations
- **SPI layer**: Changes in `spi/` or infrastructure
- **Domain**: Business logic in `application/` or domain models
- **Config**: Spring Boot configs, properties, YAML
- **Tests**: Test files, test helpers, fixtures
- **Build**: Gradle, dependencies, CI/CD
- **Docs**: README, documentation, comments

### Quality Standards
- Keep Description to 2-3 sentences max
- Focus on architectural layers, not individual files
- Use bullet points for Changes Made
- No code snippets or verbose explanations
- Only include relevant Additional Notes

## Tips

1. Use `@me` to reference yourself in MR/issue filters
2. Use `--web` to quickly open anything in browser
3. Use `glab ci lint` to validate `.gitlab-ci.yml` before pushing
4. Use `glab api` for any GitLab API endpoint not covered by commands
5. Use `glab mr for <issue-id>` to create MR linked to an issue
6. Use `--when-pipeline-succeeds` for auto-merge when CI passes
7. Use `-R owner/repo` to target a different repository
8. Combine with branch names instead of MR IDs when possible (more intuitive)
