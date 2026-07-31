# LogQL Query Reference

LogQL is Loki's query language, inspired by PromQL.

## Query Structure

```
{stream_selector} | line_filters | parser | label_filter | line_format | unwrap
```

## Stream Selectors

Select log streams by labels:

```logql
# Exact match
{service_name="customer-master-service"}

# Not equal
{service_name!="test-service"}

# Regex match
{service_name=~"customer.*"}

# Regex not match
{service_name!~"test.*"}

# Multiple conditions (AND)
{service_name="kyc-service", namespace="kyc", level="ERROR"}
```

## Line Filters

Filter log lines by content:

| Operator | Description | Example |
|----------|-------------|---------|
| `\|=` | Contains | `\|= "error"` |
| `!=` | Does not contain | `!= "debug"` |
| `\|~` | Regex match | `\|~ "(?i)exception"` |
| `!~` | Regex not match | `!~ "healthcheck"` |

```logql
# Contains string
{service_name="loan-servicing-service"} |= "disbursement"

# Case-insensitive
{service_name="kyc-service"} |~ "(?i)error"

# Multiple filters (AND)
{service_name="customer-lifecycle-service"} |= "customer" |= "created"

# Exclude patterns
{service_name="aml-service"} != "healthcheck" != "metrics"
```

## Parsers

### JSON Parser

```logql
# Parse JSON logs
{service_name="loan-origination-service"} | json

# Extract specific fields
{service_name="customer-master-service"} | json customer_id, status

# Filter by parsed field
{service_name="kyc-service"} | json | status_code >= 400
```

### Logfmt Parser

```logql
# Parse logfmt
{service_name="cbs-bridge-service"} | logfmt

# Filter by parsed field
{service_name="customer-lifecycle-service"} | logfmt | level="error"
```

### Pattern Parser

```logql
# Extract from pattern
{service_name="nginx"} | pattern `<ip> - - <_> "<method> <uri> <_>" <status>`

# Filter by extracted field
... | pattern `...` | status >= 400
```

### Regexp Parser

```logql
# Extract with regex
{service_name="app"} | regexp `(?P<timestamp>\d{4}-\d{2}-\d{2}) (?P<level>\w+)`
```

## Label Filters

Filter by parsed or existing labels:

```logql
# Equality
| level="ERROR"

# Not equal
| level!="DEBUG"

# Regex
| method=~"GET|POST"

# Comparison (numeric)
| status_code >= 400
| duration > 1000
```

## Line Format

Transform output:

```logql
# Template output
| line_format "{{.timestamp}} [{{.level}}] {{.message}}"

# Include label
| line_format "{{.service_name}}: {{.msg}}"
```

## Metric Queries

### Log Count

```logql
# Count logs per service
count_over_time({service_name="kyc-service"}[5m])

# Rate of errors
rate({service_name="loan-servicing-service", level="ERROR"}[5m])
```

### Aggregations

```logql
# Sum by label
sum by (service_name) (count_over_time({namespace="customer-data"}[1h]))

# Top services by error count
topk(5, sum by (service_name) (count_over_time({level="ERROR"}[1h])))
```

### Duration/Size Extraction

```logql
# Average request duration
avg_over_time({service_name="api"} | json | unwrap duration [5m])

# 95th percentile
quantile_over_time(0.95, {service_name="api"} | json | unwrap response_time [5m])
```

## Common Patterns for 361

### Find Customer Flow

```logql
{namespace=~"customer.*|kyc.*"} |= "CUST-12345" | json
```

### Error Analysis

```logql
{level="ERROR"} | json | line_format "{{.service_name}}: {{.message}}"
```

### Trace Correlation

```logql
{} |= "trace_id=abc123" | json service_name, message
```

### Performance Issues

```logql
{service_name="loan-origination-service"} | json | duration > 5000
```

### Orbit Integration Errors

```logql
{service_name="cbs-bridge-service"} |= "Orbit" |~ "error|failed|timeout"
```

### Temporal Workflow Issues

```logql
{namespace=~".*temporal.*"} |= "workflow" |~ "failed|error"
```

## Time Ranges

In logcli, use `--since` or `--from/--to`:

```bash
# Relative
--since=30m
--since=2h
--since=24h

# Absolute (RFC3339)
--from="2025-12-02T10:00:00Z" --to="2025-12-02T12:00:00Z"
```

In LogQL (for metric queries):

```logql
# Time range in query
count_over_time({service_name="kyc-service"}[1h])
rate({level="ERROR"}[5m])
```
