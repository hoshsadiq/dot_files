#!/usr/bin/env bash

# Update flag command for jqf - extracts the flag update logic from query.sh
# This script is called by fzf to toggle jq flags

set -euo pipefail

# Arguments passed from the parent script
preview_cmd_args_file="$1"
header_file="$2"
opt="$3"
opt_exclusive="${4:-}"

sed_args=(-i)
# Determine sed in-place flag based on OS
if [[ "$(uname -s)" == "Darwin" ]]; then
  sed_args+=('')
fi

# Toggle the flag
if grep -qF -- "$opt" "$preview_cmd_args_file"; then
  sed "${sed_args[@]}" "/^$opt/d" "$preview_cmd_args_file"
else
  # Remove exclusive option if specified
  if [[ -n $opt_exclusive ]]; then
    sed "${sed_args[@]}" "/^$opt_exclusive/d" "$preview_cmd_args_file"
  fi
  # Add the option
  printf "%s\n" "$opt" >> "$preview_cmd_args_file"
fi

# Update the header file
command cp "$preview_cmd_args_file" "$header_file"
sync
