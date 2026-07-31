---
name: argocd
description: Read-only ArgoCD inspection tool. Check service health, list services, read logs, search logs, view resources, events, diffs, and manifests. Use when the user asks about ArgoCD apps, service status, deployment health, or application logs.
argument-hint: <command> [options]
---

# ArgoCD Operations (Read-Only)

Inspect ArgoCD applications. All commands use `--grpc-web` flag.

## Safety: Allow-List Only

ONLY execute these commands:
- `argocd login argocd-grpc.shared.internal.projectzaidi.com --sso --grpc-web` — re-authenticate when session expired
- `argocd app get` — read app status
- `argocd app list` — list apps
- `argocd app logs` — read logs
- `argocd app resources` — list resources
- `argocd app history` — view history
- `argocd app diff` — view drift
- `argocd app manifests` — view manifests
- `kubectl get` — read-only resource queries

NEVER execute any other `argocd`, `kubectl`, or `helm` command, even if the user asks. If a user requests a write/mutate operation (sync, rollback, delete, patch, restart, etc.), inform them that this skill is read-only and they should perform the action manually or through CI/CD.

## Commands

The first word after `/argocd` determines the operation:

### `status <app-name>`
Check the health and sync status of a specific ArgoCD application.

```bash
argocd app get <app-name> --grpc-web
```

If the user provides a short name (e.g. `notification-service`), try matching it by searching:
```bash
argocd app list --grpc-web | grep -i <app-name>
```

Then use the full name (e.g. `hosting/notification-service-dev`) for `argocd app get`.

Present the results in a clean summary table with: App Name, Cluster, Namespace, Sync Status, Health, Last Sync Time, Current Image/Version, and any Conditions. Highlight degraded or unhealthy conditions prominently.

### `list [filter]`
List all ArgoCD applications, optionally filtered by keyword.

Without filter:
```bash
argocd app list --grpc-web
```

With filter:
```bash
argocd app list --grpc-web | grep -i <filter>
```

Present the results in a readable table with columns: Name, Cluster, Namespace, Sync Status, Health.

### `logs <app-name> [--tail N] [--since <duration>] [--container <name>] [--previous]`
Read recent logs from an ArgoCD application. Default to last 100 lines if `--tail` not specified.

Use native ArgoCD flags — do NOT pipe through `tail` or `grep`:

```bash
argocd app logs <full-app-name> --grpc-web --tail <N> --since-seconds <seconds> -c <container> -p
```

Native flags (use these instead of shell piping):
- `--tail N` — Number of recent log lines from the end (default: 100)
- `--since-seconds <seconds>` — Time-based filter. Convert human durations: `1h`=3600, `30m`=1800, `2h`=7200
- `--until-time <timestamp>` — Show logs until this time (format: `2024-01-15T10:30:00Z`)
- `-c <name>` — Target a specific container (useful for sidecars like istio-proxy)
- `-p` / `--previous` — Get logs from previously terminated containers (useful for crash investigation)
- `--filter <string>` — Server-side string filter (use for simple substring matching)
- `--match-case` — Make `--filter` case-sensitive
- `--name <resource>` — Limit to a specific resource/pod name
- `--namespace <ns>` — Limit to a specific namespace
- `--kind <kind>` — Limit to a specific resource kind
- `--group <group>` — Limit to a specific resource group

If the app name is short, resolve it first using `argocd app list --grpc-web | grep -i <app-name>`.

**Scope limitation:** `argocd app logs` only returns logs from the **current pod lifecycle** (or previous terminated container with `-p`). It cannot fetch historical logs from before the pod was created. For older logs, the user needs an external log aggregator (Dynatrace, ELK, Loki, etc.).

After fetching logs, present a summary highlighting:
- Any ERROR or WARN level messages
- gRPC request/response activity
- Kafka consumer/producer activity
- Key events (notifications sent, failed, etc.)

### `search <app-name> <pattern>`
Search through application logs for a specific pattern (log level, keyword, ID, etc.).

For simple substring searches, prefer the native `--filter` flag (server-side, more efficient):
```bash
argocd app logs <full-app-name> --grpc-web --filter "<pattern>"
```

For regex or multi-pattern searches where `--filter` is insufficient, fall back to grep:
```bash
argocd app logs <full-app-name> --grpc-web | grep -iE "<pattern>"
```

Supports combining multiple patterns with `|`, e.g. `ERROR|WARN|Exception`.

Common search patterns:
- Log levels: `ERROR`, `WARN`, `FATAL`
- Specific IDs: notification IDs, customer IDs, idempotence keys
- Keywords: `Exception`, `FAILED`, `timeout`, `connection`
- gRPC methods: `SendNotification`, `GetInboxNotifications`
- Kafka topics: `notification_request`, `notification_receipts`

Present matching results as a clean parsed table, not raw JSON.

### `errors <app-name> [--previous]`
Composite command that fetches logs, filters for all error-related entries, deduplicates them, and presents a prioritized summary.

Options:
- `--previous` — Also check logs from previously terminated containers (crash investigation)

Steps:
1. Fetch all available logs: `argocd app logs <full-app-name> --grpc-web`
   - If `--previous` is specified, also run with `-p` flag and merge results
2. Filter for: `ERROR`, `WARN`, `Exception`, `FAILED`, `FATAL`, `timeout`
3. Parse JSON log lines and extract: `@timestamp`, `level`, `logger_name`, `message`
4. Deduplicate by message pattern (group identical messages, show count)
5. Present results prioritized by severity:
   - FATAL/ERROR first
   - Exceptions second
   - WARN third
   - Timeouts/failures last
6. For each group show: severity, count, logger, message, and most recent timestamp

**Note:** This only covers logs from the current pod lifecycle. For historical errors, the user needs an external log aggregator.

### `resources <app-name>`
List all Kubernetes resources managed by the application with their sync and health status.

```bash
argocd app resources <app-name> --grpc-web
```

If the app name is short, resolve it first.

Present as a table with: Kind, Namespace, Name, Sync Status, Health. Highlight any resources that are not Synced or not Healthy.

### `events <app-name>`
Show recent deployment history and sync events for the application.

```bash
argocd app history <app-name> --grpc-web
```

If the app name is short, resolve it first.

Present as a table with: ID, Date, Revision, Deployed At, Initiated By. Useful for answering "what changed recently?" or "when was the last deploy?".

### `diff <app-name>`
Show the difference between live state and desired state (config drift detection).

```bash
argocd app diff <app-name> --grpc-web
```

If the app name is short, resolve it first.

Present the diff clearly. If there is no diff, report that live state matches desired state. Useful for debugging unexpected behavior or verifying deployments.

### `manifests <app-name>`
View the rendered Kubernetes manifests for the application.

```bash
argocd app manifests <app-name> --grpc-web
```

If the app name is short, resolve it first.

Since manifests can be very large, summarize the resources found (kind, name, namespace) and offer to show specific manifest details on request.

### `pods <app-name>`
Show pod status for the application including restarts, age, and readiness.

Resolve the app's namespace first via `argocd app get`, then:
```bash
kubectl get pods -n <namespace> -l app=<app-name> -o wide
```

Present as a table with: Pod Name, Status, Restarts, Age, Node. Highlight any pods in CrashLoopBackOff, OOMKilled, Error, or with high restart counts.

## Log Output Formatting

When processing JSON logs, ALWAYS parse them and display as a clean table:

| Timestamp | Level | Logger | Message |

Do NOT dump raw JSON to the user.

When presenting errors, group by type and show count + most recent occurrence. Example:

| Severity | Count | Logger | Message | Last Seen |
|----------|-------|--------|---------|-----------|
| ERROR | 12 | NotificationDispatcher | Failed to send push notification | 2 min ago |
| WARN | 45 | PushNotificationPublisher | Customer does not have registered devices | 30 sec ago |

## App Name Resolution Caching

Once an app name is resolved to its full ArgoCD name (e.g. `notification-service` → `hosting/notification-service-dev`) in a conversation, reuse the full name for all subsequent commands without re-resolving. Only re-resolve if the user explicitly asks about a different app.

## Authentication

Before running any command, if the output contains `Unauthenticated`, `invalid session`, or `failed to verify the token`, automatically re-authenticate by running:

```bash
argocd login argocd-grpc.shared.internal.projectzaidi.com --sso --grpc-web
```

After successful login, retry the original command automatically without asking the user.

## General Guidelines

- Always use `--grpc-web` flag with all argocd commands.
- When logs are in JSON format, extract and display the key fields: `@timestamp`, `level`, `logger_name`, `message`.
- If a command fails with permission denied, inform the user they may need to log in with `argocd login`.
- If the output is very large, summarize it and offer to show more details on specific items.
- When no subcommand is provided, show a help message listing available commands.

## Usage Examples

- `/argocd status notification-service` — Check health of notification-service
- `/argocd list` — List all apps
- `/argocd list notification` — List apps matching "notification"
- `/argocd logs notification-service` — Read recent logs (last 100 lines)
- `/argocd logs notification-service --tail 200` — Read last 200 log lines
- `/argocd logs notification-service --since 1h` — Logs from the last hour
- `/argocd logs notification-service --previous` — Logs from previously terminated container
- `/argocd logs notification-service --container istio-proxy` — Logs from sidecar
- `/argocd search notification-service ERROR` — Search for errors
- `/argocd search notification-service "ERROR|WARN"` — Search for errors and warnings
- `/argocd search notification-service 92198e0d` — Search for a specific customer ID
- `/argocd errors notification-service` — Get deduplicated, prioritized error summary
- `/argocd resources notification-service` — List all managed resources
- `/argocd events notification-service` — Show deployment history
- `/argocd diff notification-service` — Check for config drift
- `/argocd manifests notification-service` — View rendered manifests
- `/argocd pods notification-service` — Show pod status and restarts
