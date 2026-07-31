---
name: confluence-cli
description: Interact with Atlassian Confluence using confluence-cli (https://github.com/pchuri/confluence-cli). Use for reading pages, searching content, creating/updating pages, listing spaces, copying page trees, and any Confluence-related operations.
---

# Confluence CLI

Use `confluence` command-line tool for all Confluence interactions. This is the primary way to manage Confluence content from the terminal.

## Prerequisites

- Node.js installed
- Install globally: `npm install -g confluence-cli`
- Or run with npx: `npx confluence-cli`
- Run `confluence init` to configure authentication

## Quick Reference

### Authentication & Setup

```bash
# Interactive setup (recommended)
confluence init

# Check current configuration
cat ~/.confluence-cli/config.json
```

### Environment Variables

```bash
export CONFLUENCE_DOMAIN="your-domain.atlassian.net"
export CONFLUENCE_API_TOKEN="your-api-token"
export CONFLUENCE_EMAIL="your.email@example.com"  # Required for Atlassian Cloud
export CONFLUENCE_API_PATH="/wiki/rest/api"       # Cloud default; use /rest/api for Server/DC
export CONFLUENCE_AUTH_TYPE="basic"               # Or "bearer" for self-hosted
```

### Getting API Token

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a label (e.g., "confluence-cli")
4. Copy the generated token

## Commands Reference

### Read Pages

```bash
# Read by page ID (text format)
confluence read 123456789

# Read in markdown format
confluence read 123456789 --format markdown

# Read in HTML format
confluence read 123456789 --format html

# Read by URL
confluence read "https://your-domain.atlassian.net/wiki/viewpage.action?pageId=123456789"
```

### Get Page Information

```bash
confluence info 123456789
```

### Search Pages

```bash
# Basic search
confluence search "search term"

# Limit results
confluence search "search term" --limit 5
```

### List Spaces

```bash
confluence spaces
```

### Find Page by Title

```bash
# Find page by title
confluence find "Project Documentation"

# Find in specific space
confluence find "Project Documentation" --space MYTEAM
```

### Create Pages

```bash
# Create with inline content
confluence create "My New Page" SPACEKEY --content "**Hello** World!" --format markdown

# Create from file
confluence create "Documentation" SPACEKEY --file ./content.md --format markdown

# Supported formats: storage, html, markdown
```

### Create Child Pages

```bash
# Create child page with inline content
confluence create-child "Meeting Notes" 123456789 --content "This is a child page"

# Create from file
confluence create-child "Tech Specs" 123456789 --file ./specs.md --format markdown
```

### Update Pages

```bash
# Update title only
confluence update 123456789 --title "New Page Title"

# Update content only
confluence update 123456789 --content "Updated content"

# Update from file
confluence update 123456789 --file ./updated-content.md --format markdown

# Update both title and content
confluence update 123456789 --title "New Title" --content "New content"
```

### Edit Workflow

```bash
# 1. Export page content to file (Confluence storage format)
confluence edit 123456789 --output ./page-to-edit.xml

# 2. Edit file with your preferred editor
vim ./page-to-edit.xml

# 3. Update the page with changes
confluence update 123456789 --file ./page-to-edit.xml --format storage
```

### Copy Page Tree

```bash
# Copy page and all children to a new location
confluence copy-tree 123456789 987654321 "Project Docs (Copy)"

# Limit depth (only 3 levels deep)
confluence copy-tree 123456789 987654321 --max-depth 3

# Exclude pages by title (wildcards supported)
confluence copy-tree 123456789 987654321 --exclude "temp*,test*,*draft*"

# Control pacing and naming
confluence copy-tree 123456789 987654321 --delay-ms 150 --copy-suffix " (Backup)"

# Dry run (preview only)
confluence copy-tree 123456789 987654321 --dry-run

# Quiet mode
confluence copy-tree 123456789 987654321 --quiet

# Fail on error (exit non-zero if any page fails)
confluence copy-tree 123456789 987654321 --fail-on-error
```

### View Statistics

```bash
confluence stats
```

## Command Summary Table

| Command | Description | Key Options |
|---------|-------------|-------------|
| `init` | Initialize CLI configuration | - |
| `read <pageId>` | Read page content | `--format <html\|text\|markdown>` |
| `info <pageId>` | Get page information | - |
| `search <query>` | Search for pages | `--limit <number>` |
| `spaces` | List all spaces | - |
| `find <title>` | Find page by title | `--space <spaceKey>` |
| `create <title> <spaceKey>` | Create new page | `--content`, `--file`, `--format` |
| `create-child <title> <parentId>` | Create child page | `--content`, `--file`, `--format` |
| `copy-tree <sourceId> <targetParentId>` | Copy page tree | `--max-depth`, `--exclude`, `--dry-run` |
| `update <pageId>` | Update page | `--title`, `--content`, `--file`, `--format` |
| `edit <pageId>` | Export for editing | `--output <file>` |
| `stats` | View usage statistics | - |

## Common Workflows

### Export Page to Markdown, Edit, and Update

```bash
# Read current content as markdown
confluence read 123456789 --format markdown > page.md

# Edit the file
vim page.md

# Update the page
confluence update 123456789 --file page.md --format markdown
```

### Create Documentation Structure

```bash
# Create parent page
confluence create "Project Documentation" PROJ --content "Main documentation page"

# Get the page ID from the output, then create children
confluence create-child "Architecture" <parent-id> --file ./arch.md --format markdown
confluence create-child "API Reference" <parent-id> --file ./api.md --format markdown
```

### Backup a Page Tree

```bash
# Dry run first to preview
confluence copy-tree 123456789 987654321 "Backup" --dry-run

# Execute the backup
confluence copy-tree 123456789 987654321 "Backup (2025-12-01)" --copy-suffix ""
```

### Search and Read Workflow

```bash
# Search for pages
confluence search "deployment guide" --limit 10

# Get page ID from results, then read
confluence read <pageId> --format markdown
```

## Tips

1. Use `--format markdown` for human-readable output
2. Use `--dry-run` with `copy-tree` to preview before copying
3. Page IDs can be found in the URL or via `search`/`find` commands
4. Use `confluence info <pageId>` to get page metadata including version info
5. For bulk operations, consider using `copy-tree` with appropriate `--exclude` patterns
6. Set `CONFLUENCE_CLI_ANALYTICS=false` to disable anonymous usage tracking
