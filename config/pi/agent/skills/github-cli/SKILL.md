---
name: GitHub CLI
description: Interact with GitHub using gh CLI (https://github.com/cli/cli). Use for pull requests, issues, repos, workflows, releases, gists, and any GitHub-related operations. Triggers on "github", "gh", "pull request", "PR", "issue", "repo", "workflow", "release", "gist", "clone", "fork".
---

# GitHub CLI

Use `gh` command-line tool for all GitHub interactions. This is the primary way to manage GitHub resources on this machine.

## Prerequisites

- `gh` CLI must be installed (`brew install gh`)
- Run `gh auth login` to authenticate with GitHub
- Optionally set `GITHUB_TOKEN` environment variable

## Quick Reference

### Authentication

```bash
# Login interactively
gh auth login

# Login with token
gh auth login --with-token < token.txt

# Check auth status
gh auth status

# Switch between accounts
gh auth switch

# Logout
gh auth logout
```

### Pull Request Operations

```bash
# List PRs
gh pr list                              # Open PRs in current repo
gh pr list --state all                  # All PRs
gh pr list --state closed               # Closed PRs
gh pr list --assignee @me               # Assigned to me
gh pr list --author @me                 # Created by me
gh pr list --search "review:required"   # Needing review

# View PR
gh pr view                              # Current branch's PR
gh pr view 123                          # By number
gh pr view --web                        # Open in browser
gh pr view --comments                   # With comments

# Create PR
gh pr create                            # Interactive
gh pr create --title "Title" --body "Body"
gh pr create --fill                     # Auto-fill from commits
gh pr create --draft                    # Create as draft
gh pr create --base main                # Target branch
gh pr create --web                      # In browser

# Checkout PR
gh pr checkout 123                      # By number
gh pr checkout branch-name              # By branch

# Review PR
gh pr review                            # Interactive
gh pr review --approve                  # Approve
gh pr review --request-changes -b "feedback"
gh pr review --comment -b "comment"

# Merge PR
gh pr merge                             # Current branch
gh pr merge 123                         # By number
gh pr merge --merge                     # Merge commit
gh pr merge --squash                    # Squash and merge
gh pr merge --rebase                    # Rebase and merge
gh pr merge --auto                      # Auto-merge when ready
gh pr merge --delete-branch             # Delete branch after

# Other PR operations
gh pr ready                             # Mark as ready for review
gh pr close 123                         # Close PR
gh pr reopen 123                        # Reopen PR
gh pr edit 123 --title "New title"      # Edit PR
gh pr diff                              # View diff
gh pr checks                            # View CI status
gh pr status                            # Your PR status summary
```

### Issue Operations

```bash
# List issues
gh issue list                           # Open issues
gh issue list --state all               # All issues
gh issue list --state closed            # Closed issues
gh issue list --assignee @me            # Assigned to me
gh issue list --author @me              # Created by me
gh issue list --label "bug"             # By label
gh issue list --milestone "v1.0"        # By milestone
gh issue list --search "is:open sort:updated-desc"

# View issue
gh issue view 123                       # By number
gh issue view 123 --web                 # Open in browser
gh issue view 123 --comments            # With comments

# Create issue
gh issue create                         # Interactive
gh issue create --title "Title" --body "Body"
gh issue create --label "bug,urgent"
gh issue create --assignee @me
gh issue create --milestone "v1.0"
gh issue create --web                   # In browser

# Edit issue
gh issue edit 123 --title "New title"
gh issue edit 123 --body "New body"
gh issue edit 123 --add-label "bug"
gh issue edit 123 --remove-label "wontfix"
gh issue edit 123 --add-assignee user

# Close/Reopen
gh issue close 123
gh issue close 123 --reason "not planned"
gh issue reopen 123

# Other
gh issue status                         # Your issue status summary
gh issue comment 123 --body "Comment"
gh issue pin 123
gh issue unpin 123
gh issue transfer 123 owner/repo
gh issue develop 123                    # Create branch for issue
```

### Repository Operations

```bash
# Clone
gh repo clone owner/repo                # Clone repo
gh repo clone owner/repo -- --depth 1   # Shallow clone

# Create
gh repo create my-repo                  # Interactive
gh repo create my-repo --public
gh repo create my-repo --private
gh repo create my-repo --clone          # Clone after creation
gh repo create --source . --push        # From existing directory

# Fork
gh repo fork                            # Fork current repo
gh repo fork owner/repo                 # Fork specific repo
gh repo fork --clone                    # Clone after forking
gh repo fork --remote                   # Add remote

# View
gh repo view                            # Current repo
gh repo view owner/repo                 # Specific repo
gh repo view --web                      # Open in browser

# List
gh repo list                            # Your repos
gh repo list owner                      # User/org repos
gh repo list --source                   # Non-forks only
gh repo list --fork                     # Forks only

# Other
gh repo edit --default-branch main
gh repo edit --visibility public
gh repo rename new-name
gh repo delete owner/repo --yes
gh repo archive owner/repo
gh repo sync                            # Sync fork with upstream
```

### Workflow/Actions Operations

```bash
# List workflows
gh workflow list
gh workflow list --all                  # Include disabled

# View workflow
gh workflow view                        # Interactive
gh workflow view workflow.yml

# Run workflow
gh run list                             # List runs
gh run list --workflow workflow.yml
gh run list --status failure

gh run view                             # Interactive
gh run view 12345                       # By run ID
gh run view --web                       # Open in browser
gh run view --log                       # View logs

gh run watch                            # Watch current run
gh run watch 12345                      # Watch specific run

gh run rerun 12345                      # Rerun failed jobs
gh run rerun 12345 --failed             # Only failed jobs
gh run cancel 12345                     # Cancel run

gh workflow run workflow.yml            # Trigger workflow
gh workflow run workflow.yml -f param=value

# Workflow enable/disable
gh workflow enable workflow.yml
gh workflow disable workflow.yml
```

### Release Operations

```bash
# List releases
gh release list

# View release
gh release view                         # Latest
gh release view v1.0.0                  # Specific version
gh release view --web                   # Open in browser

# Create release
gh release create v1.0.0                # Interactive
gh release create v1.0.0 --title "v1.0"
gh release create v1.0.0 --notes "Release notes"
gh release create v1.0.0 --generate-notes
gh release create v1.0.0 --draft
gh release create v1.0.0 --prerelease
gh release create v1.0.0 ./dist/*       # With assets

# Edit release
gh release edit v1.0.0 --title "New title"
gh release edit v1.0.0 --draft=false

# Delete release
gh release delete v1.0.0 --yes

# Download assets
gh release download                     # Latest
gh release download v1.0.0              # Specific version
gh release download v1.0.0 --pattern "*.tar.gz"
```

### Gist Operations

```bash
# List gists
gh gist list
gh gist list --public
gh gist list --secret

# View gist
gh gist view GIST_ID
gh gist view GIST_ID --web

# Create gist
gh gist create file.txt                 # Single file
gh gist create file1.txt file2.txt      # Multiple files
gh gist create --public file.txt        # Public gist
gh gist create -d "Description" file.txt

# Edit gist
gh gist edit GIST_ID
gh gist edit GIST_ID --add newfile.txt

# Delete gist
gh gist delete GIST_ID

# Clone gist
gh gist clone GIST_ID
```

### Search Operations

```bash
# Search repos
gh search repos "query"
gh search repos "query" --language kotlin
gh search repos "query" --owner org

# Search issues/PRs
gh search issues "query"
gh search issues "query" --state open
gh search issues "query" --repo owner/repo

gh search prs "query"
gh search prs "query" --state merged

# Search code
gh search code "query"
gh search code "query" --repo owner/repo

# Search commits
gh search commits "query"
```

### API Operations

```bash
# Make API calls
gh api /user                            # GET request
gh api /repos/owner/repo/issues         # List issues via API
gh api -X POST /repos/owner/repo/issues -f title="Title" -f body="Body"
gh api graphql -f query='{ viewer { login } }'

# Pagination
gh api /repos/owner/repo/issues --paginate

# Output formatting
gh api /user --jq '.login'
gh api /user -t '{{.login}}'
```

### Other Useful Commands

```bash
# Open in browser
gh browse                               # Repo
gh browse issues                        # Issues page
gh browse --settings                    # Settings

# Status
gh status                               # Your notifications/mentions

# Config
gh config set editor vim
gh config set git_protocol ssh
gh config list

# Extensions
gh extension list
gh extension install owner/gh-extension
gh extension upgrade --all

# Labels
gh label list
gh label create "bug" --color "FF0000"
gh label delete "wontfix"

# Secrets (for Actions)
gh secret list
gh secret set SECRET_NAME
gh secret delete SECRET_NAME

# Codespaces
gh codespace list
gh codespace create
gh codespace ssh
gh codespace stop
```

## Common Workflows

### Create PR from current branch
```bash
git push -u origin HEAD
gh pr create --fill
```

### Review and merge PR
```bash
gh pr checkout 123
# ... review code ...
gh pr review --approve
gh pr merge --squash --delete-branch
```

### Create issue and branch
```bash
gh issue create --title "Bug fix" --label "bug"
gh issue develop 123 --checkout
```

### Sync fork with upstream
```bash
gh repo sync owner/fork -b main
```

### Watch CI and merge when ready
```bash
gh pr merge --auto --squash
gh run watch
```

### Quick release
```bash
gh release create v1.0.0 --generate-notes ./dist/*
```

## Output Formats

- **Default**: Colorized terminal output
- **--json**: JSON output with specific fields
- **--jq**: Process JSON with jq expressions
- **--template / -t**: Go template formatting
- **--web / -w**: Open in browser

## Tips

1. Use `@me` to reference yourself in filters
2. Use `--web` to quickly open anything in browser
3. Use `gh pr status` and `gh issue status` for quick overview
4. Use `gh api` for any GitHub API endpoint
5. Use `--json field1,field2 --jq '.[]'` for scripting
6. Combine with `fzf` for fuzzy selection: `gh pr list | fzf`
7. Use `gh run watch` to monitor CI in terminal
