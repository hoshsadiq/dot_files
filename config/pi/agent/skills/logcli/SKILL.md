---
name: LogCLI - Grafana Loki Logs
description: Query and analyze Grafana Loki logs using logcli CLI. Use when investigating errors, debugging issues, searching logs, tailing services, or analyzing log patterns. Triggers on "logs", "loki", "debug", "error", "trace", "logcli", "investigate".
---

# LogCLI - Grafana Loki Log Analysis

Query and analyze logs from Grafana Loki for the 361 by FINCA platform.

## Quick Start (Wrapper Script)

Use the wrapper script [scripts/loki.sh](scripts/loki.sh) which auto-loads environment:

```bash
# Shortcuts (no source .env needed!)
.claude/skills/logcli/scripts/loki.sh services              # List all services
.claude/skills/logcli/scripts/loki.sh errors kyc-service    # Show errors
.claude/skills/logcli/scripts/loki.sh tail loan-origination # Tail logs
.claude/skills/logcli/scripts/loki.sh search "CUST-12345"   # Search text

# Query with LogQL
.claude/skills/logcli/scripts/loki.sh query '{service_name="customer-lifecycle-service"}'

# Switch environment
.claude/skills/logcli/scripts/loki.sh --env preprod services
.claude/skills/logcli/scripts/loki.sh --env prod errors loan-servicing

# Service name shortcuts (auto-appends -service)
.claude/skills/logcli/scripts/loki.sh kyc                   # Query kyc-service
.claude/skills/logcli/scripts/loki.sh tail customer-master  # Tail customer-master-service
```

## Prerequisites

### Installation

```bash
# macOS via Homebrew
brew install grafana/grafana/logcli
```

### 361 Environment URLs

| Environment | `--env` flag | Loki URL |
|-------------|--------------|----------|
| **DEV (Client)** | `dev` | `http://loki.dev.cinnamon-bun.com` |
| **DEV (Global)** | `dev-global` | `http://loki.dev.global.cinnamon-bun.com` |
| **PREPROD (Malawi)** | `preprod` | `http://loki.preprod.chocolate-brownie.com` |
| **PREPROD (Global)** | `preprod-global` | `http://loki.preprod.global.cinnamon-bun.com` |
| **PROD (Malawi)** | `prod` | `http://loki.prod.chocolate-brownie.com` |
| **PROD (Global)** | `prod-global` | `http://loki.prod.global.cinnamon-bun.com` |

**Note:** VPN connection required for all environments.

## Core Commands

| Command | Purpose |
|---------|---------|
| `query` | Execute LogQL queries for log retrieval |
| `labels` | Discover available labels and values |
| `series` | Find log streams matching label matchers |
| `instant-query` | Evaluate metric queries at single point |
| `stats` | Retrieve index statistics |

## Instructions

### 1. Discover Available Labels

First, find what labels are available:
```bash
logcli labels                              # List all label names
logcli labels service_name                 # List values for service_name
logcli labels namespace                    # List namespaces
```

### 2. Basic Log Queries

Query logs by service:
```bash
# Query specific service
logcli query '{service_name="customer-master-service"}' --limit=50

# Query by namespace
logcli query '{namespace="customer-data"}' --limit=20

# Query with keyword filter
logcli query '{service_name="kyc-service"} |= "error"' --limit=30

# Case-insensitive search
logcli query '{service_name="loan-origination-service"} |~ "(?i)exception"'
```

### 3. Filter by Log Level

```bash
# ERROR logs only
logcli query '{service_name="customer-lifecycle-service", level="ERROR"}' --limit=50

# WARN and ERROR
logcli query '{service_name="loan-servicing-service"} | level=~"ERROR|WARN"'
```

### 4. Time Range Queries

```bash
# Last 30 minutes
logcli query '{service_name="aml-service"}' --since=30m

# Last 2 hours
logcli query '{service_name="kyc-service"}' --since=2h

# Specific time range (UTC)
logcli query '{service_name="customer-master-service"}' \
  --from="2025-12-02T10:00:00Z" \
  --to="2025-12-02T12:00:00Z"

# Today's logs
logcli query '{service_name="loan-origination-service"}' --since=24h
```

### 5. Tail Logs (Live Stream)

```bash
# Follow logs in real-time
logcli query '{service_name="customer-lifecycle-service"}' --tail

# Tail with filter
logcli query '{service_name="kyc-service"} |= "customer_id"' --tail
```

### 6. Search by Customer/Transaction ID

```bash
# Find logs for specific customer
logcli query '{namespace=~"customer.*"} |= "CUST-12345"' --limit=100

# Find by transaction ID
logcli query '{namespace=~"loan.*"} |= "TXN-67890"' --limit=100

# Search across all services
logcli query '{} |= "correlation_id=abc123"' --limit=200
```

### 7. JSON Log Parsing

For structured JSON logs:
```bash
# Parse JSON and filter
logcli query '{service_name="loan-servicing-service"} | json | level="ERROR"'

# Extract specific fields
logcli query '{service_name="customer-master-service"} | json | customer_id != ""'

# Filter by parsed field
logcli query '{service_name="kyc-service"} | json | status_code >= 400'
```

### 8. Output Formats

```bash
# Raw output (no labels)
logcli query '{service_name="aml-service"}' --output=raw --limit=20

# JSON lines (for scripting)
logcli query '{service_name="loan-origination-service"}' --output=jsonl --limit=50

# Quiet mode (no metadata)
logcli query '{service_name="customer-lifecycle-service"}' --quiet

# Include statistics
logcli query '{service_name="kyc-service"}' --stats
```

### 9. Analyze Series and Volume

```bash
# List all streams for a service
logcli series '{service_name="customer-master-service"}'

# Analyze label cardinality
logcli series '{namespace="customer-data"}' --analyze-labels

# Get log volume statistics
logcli stats '{service_name="loan-servicing-service"}' --since=24h
```

## Common Investigation Workflows

### Workflow 1: Debug Customer Onboarding Issue

```bash
# 1. Find customer-related logs
logcli labels service_name | grep -i customer

# 2. Search for customer ID
logcli query '{namespace=~"customer.*"} |= "CUST-12345"' --since=1h --limit=100

# 3. Check for errors
logcli query '{service_name="customer-lifecycle-service", level="ERROR"}' --since=1h

# 4. Trace the flow
logcli query '{namespace=~"customer.*|kyc.*"} |= "CUST-12345"' --since=2h --output=jsonl
```

### Workflow 2: Investigate Loan Processing Error

```bash
# 1. Find loan service errors
logcli query '{service_name="loan-origination-service", level="ERROR"}' --since=30m

# 2. Search for specific loan
logcli query '{namespace=~"loan.*"} |= "LOAN-789"' --since=2h

# 3. Check downstream services
logcli query '{service_name=~"loan-servicing.*|cbs-bridge.*"} |= "LOAN-789"' --since=2h
```

### Workflow 3: Monitor Service Health

```bash
# 1. Error rate check
logcli query 'rate({service_name="kyc-service", level="ERROR"}[5m])' --since=1h

# 2. Tail for live issues
logcli query '{service_name="kyc-service", level=~"ERROR|WARN"}' --tail

# 3. Check specific timeouts
logcli query '{service_name="aml-service"} |~ "timeout|timed out"' --since=1h
```

## 361 Service Names Reference

| Bounded Context | Service Name |
|-----------------|--------------|
| Customer Data | `customer-master-service` |
| Customer Lifecycle | `customer-lifecycle-service` |
| KYC | `kyc-service` |
| AML | `aml-service` |
| Customer Risk | `customer-risk-assessment-service` |
| Loan Origination | `loan-origination-service` |
| Loan Servicing | `loan-servicing-service` |
| Business Lending | `business-lending-service` |
| CBS Bridge | `cbs-bridge-service` |
| Delinquency | `delinquency-service` |
| Soft Collections | `soft-collections-service` |

## Useful Flags Reference

| Flag | Description | Example |
|------|-------------|---------|
| `--limit` | Max results (0=all) | `--limit=100` |
| `--since` | Lookback window | `--since=2h` |
| `--from/--to` | Time range (RFC3339) | `--from="2025-12-02T10:00:00Z"` |
| `--tail/-t` | Live streaming | `--tail` |
| `--output/-o` | Format: default/raw/jsonl | `--output=jsonl` |
| `--quiet/-q` | Suppress metadata | `--quiet` |
| `--stats` | Show statistics | `--stats` |
| `--no-labels` | Hide labels | `--no-labels` |
| `--timezone/-z` | Local or UTC | `--timezone=UTC` |

## Examples

### Example 1: Customer Not Onboarding

User request: "Customer with ID CUST-54321 is stuck in onboarding"

```bash
# Search across customer services
logcli query '{namespace=~"customer.*"} |= "CUST-54321"' --since=24h --limit=200

# Check for errors in lifecycle service
logcli query '{service_name="customer-lifecycle-service"} |= "CUST-54321"' --since=24h

# Check KYC status
logcli query '{service_name="kyc-service"} |= "CUST-54321"' --since=24h

# Look for workflow errors
logcli query '{namespace=~"customer.*"} |= "CUST-54321" | json | level="ERROR"'
```

### Example 2: Loan Disbursement Failed

User request: "Loan LOAN-98765 disbursement failed"

```bash
# Find loan in origination
logcli query '{service_name="loan-origination-service"} |= "LOAN-98765"' --since=48h

# Check CBS bridge for Orbit errors
logcli query '{service_name="cbs-bridge-service"} |= "LOAN-98765"' --since=48h

# Look for transaction errors
logcli query '{namespace=~"loan.*"} |= "disbursement" |= "error"' --since=24h
```

### Example 3: Tail Production Errors

```bash
# Watch all ERROR logs across services
logcli query '{level="ERROR"}' --tail

# Watch specific service
logcli query '{service_name="customer-master-service", level="ERROR"}' --tail
```
