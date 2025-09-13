#!/usr/bin/env bash

# From: https://gist.github.com/tarqd/45f5b9753f1cafcc45d7bf71efda15c6

set -euo pipefail

# Default settings
COLOR="true"
SHOW_TYPES="false"
SHOW_SIZES="false"
COLLAPSE_EMPTY="false"
FOCUS_PATH=""

# Function to display help
show_help() {
  echo "Usage: $0 [OPTIONS] <json-file?>"
  echo "Visualize JSON structures as ASCII trees"
  echo
  echo "Options:"
  echo "  -h, --help             Show this help message"
  echo "  -c, --color [on|off]   Enable/disable colored output (default: on)"
  echo "  -t, --types            Show type indicators (e.g., {}, [], str)"
  echo "  -s, --sizes            Show sizes for arrays and objects"
  echo "  -e, --collapse-empty   Collapse empty arrays and objects"
  echo "  -a, --all              Enable all visualization options"
  echo "  -f, --focus PATH       Focus on a specific path (e.g. 'users.active')"
  echo "  -m, --max-depth N      Limit the tree depth to N levels"
  echo
  echo "Examples:"
  echo "  $0 example.json                    # Basic visualization"
  echo "  $0 --types example.json            # Show with type indicators"
  echo "  $0 --all example.json              # Enable all enhancements"
  echo "  $0 --focus users.active example.json  # Focus on specific path"
  echo "  cat example.json | $0 -            # Read from stdin"
  echo
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    -c|--color)
      if [[ "$2" == "off" ]]; then
        COLOR="false"
        shift
      else
        COLOR="true"
      fi
      ;;
    -t|--types)
      SHOW_TYPES="true"
      ;;
    -s|--sizes)
      SHOW_SIZES="true"
      ;;
    -e|--collapse-empty)
      COLLAPSE_EMPTY="true"
      ;;
    -a|--all)
      SHOW_TYPES="true"
      SHOW_SIZES="true"
      COLLAPSE_EMPTY="true"
      ;;
    -f|--focus)
      if [[ -z "$2" || "$2" == -* ]]; then
        echo "Error: --focus requires a path argument" >&2
        exit 1
      fi
      FOCUS_PATH="$2"
      shift
      ;;
    -m|--max-depth)
      if [[ -z "$2" || "$2" == -* ]]; then
        echo "Error: --max-depth requires a numeric argument" >&2
        exit 1
      fi
      MAX_DEPTH="$2"
      shift
      ;;

  esac
  break
done

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Export environment variables for jq
export COLOR=$COLOR
export SHOW_TYPES=$SHOW_TYPES
export SHOW_SIZES=$SHOW_SIZES
export COLLAPSE_EMPTY=$COLLAPSE_EMPTY
export FOCUS_PATH=$FOCUS_PATH

exec jq --raw-output --from-file "$DIR/tree.jq" "$@"
