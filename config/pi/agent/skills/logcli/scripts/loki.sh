#!/usr/bin/env bash
# loki.sh - Wrapper script for logcli with automatic environment setup
# Usage: ./loki.sh [command] [args...]

set -e

# Find project root (where .env is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

# Load .env if exists and LOKI_ADDR not set
if [[ -z "$LOKI_ADDR" ]]; then
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        source "$PROJECT_ROOT/.env"
    fi
fi

# Default to DEV if still not set
export LOKI_ADDR="${LOKI_ADDR:-http://loki.dev.cinnamon-bun.com:80}"

# Get environment URL by name
get_env_url() {
    case "$1" in
        dev)           echo "http://loki.dev.cinnamon-bun.com:80" ;;
        dev-global)    echo "http://loki.dev.global.cinnamon-bun.com:80" ;;
        preprod)       echo "http://loki.preprod.chocolate-brownie.com:80" ;;
        preprod-global) echo "http://loki.preprod.global.cinnamon-bun.com:80" ;;
        prod)          echo "http://loki.prod.chocolate-brownie.com:80" ;;
        prod-global)   echo "http://loki.prod.global.cinnamon-bun.com:80" ;;
        *) echo "" ;;
    esac
}

# Help message
show_help() {
    cat << 'EOF'
loki.sh - 361 Loki Log Query Tool

USAGE:
    loki.sh [OPTIONS] <COMMAND> [ARGS...]
    loki.sh --env <ENV> <COMMAND> [ARGS...]

ENVIRONMENTS (--env):
    dev            Client DEV (default)
    dev-global     Global DEV
    preprod        Malawi PREPROD
    preprod-global Global PREPROD
    prod           Malawi PROD
    prod-global    Global PROD

COMMANDS:
    query <logql>     Query logs (default: last 1h, limit 30)
    tail <logql>      Tail logs in real-time
    labels [name]     List labels or label values
    services          List all service names
    errors <service>  Show ERROR logs for service
    search <text>     Search all logs for text

SHORTCUTS:
    loki.sh services                    # List all services
    loki.sh errors kyc-service          # Errors from kyc-service
    loki.sh tail loan-origination       # Tail loan-origination-service
    loki.sh search "CUST-12345"         # Search for customer ID

EXAMPLES:
    # Query specific service
    loki.sh query '{service_name="customer-lifecycle-service"}'

    # Query with time range
    loki.sh query '{service_name="kyc-service"}' --since=2h --limit=100

    # Use different environment
    loki.sh --env preprod query '{service_name="loan-servicing-service"}'

    # Tail errors across all services
    loki.sh tail '{level="ERROR"}'

EOF
}

# Parse --env flag
if [[ "$1" == "--env" ]]; then
    ENV_NAME="$2"
    ENV_URL=$(get_env_url "$ENV_NAME")
    if [[ -n "$ENV_URL" ]]; then
        export LOKI_ADDR="$ENV_URL"
        shift 2
    else
        echo "Unknown environment: $ENV_NAME"
        echo "Available: dev, dev-global, preprod, preprod-global, prod, prod-global"
        exit 1
    fi
fi

# Handle commands
case "$1" in
    -h|--help|help)
        show_help
        exit 0
        ;;
    services)
        # List all service names
        logcli labels service_name 2>/dev/null | grep -v "^20"
        ;;
    errors)
        # Show errors for a service
        SERVICE="$2"
        if [[ -z "$SERVICE" ]]; then
            echo "Usage: loki.sh errors <service-name>"
            exit 1
        fi
        # Auto-append -service if not present
        [[ "$SERVICE" != *-service ]] && SERVICE="${SERVICE}-service"
        shift 2
        # Only add default limit if not specified
        if [[ "$*" != *--limit* ]]; then
            logcli query "{service_name=\"$SERVICE\", level=\"ERROR\"}" --limit=50 "$@"
        else
            logcli query "{service_name=\"$SERVICE\", level=\"ERROR\"}" "$@"
        fi
        ;;
    tail)
        shift
        QUERY="$1"
        # If it's a service name shortcut
        if [[ "$QUERY" != "{"* ]]; then
            [[ "$QUERY" != *-service ]] && QUERY="${QUERY}-service"
            QUERY="{service_name=\"$QUERY\"}"
        fi
        shift
        logcli query "$QUERY" --tail "$@"
        ;;
    search)
        # Search all logs for text
        TEXT="$2"
        if [[ -z "$TEXT" ]]; then
            echo "Usage: loki.sh search <text>"
            exit 1
        fi
        shift 2
        # Only add default limit if not specified
        if [[ "$*" != *--limit* ]]; then
            logcli query "{} |= \"$TEXT\"" --limit=100 "$@"
        else
            logcli query "{} |= \"$TEXT\"" "$@"
        fi
        ;;
    labels|query|instant-query|series|stats|volume)
        # Pass through to logcli
        logcli "$@"
        ;;
    "")
        show_help
        exit 0
        ;;
    *)
        # Default: treat as query if starts with {, otherwise as service name
        if [[ "$1" == "{"* ]]; then
            logcli query "$@"
        else
            # Assume it's a service name shortcut
            SERVICE="$1"
            [[ "$SERVICE" != *-service ]] && SERVICE="${SERVICE}-service"
            shift
            # Only add default limit if not specified
            if [[ "$*" != *--limit* ]]; then
                logcli query "{service_name=\"$SERVICE\"}" --limit=30 "$@"
            else
                logcli query "{service_name=\"$SERVICE\"}" "$@"
            fi
        fi
        ;;
esac
