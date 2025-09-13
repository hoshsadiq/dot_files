#!/usr/bin/env bash

# Preview command for jqf - extracts the preview logic from query.sh
# This script is called by fzf with the query as {q} placeholder

set -euo pipefail

# Arguments passed from the parent script
tmp_dir="$1"
query="$2"
shift 2
inputs=("$@")

preview_cmd_args_file="$tmp_dir/args"
header_file="$tmp_dir/header"

# Default to "." if no query provided
[ -z "$query" ] && query="."

jq_args=()

while IFS='' read -r arg; do
  arg="${arg#"${arg%%[![:space:]]*}"}" # remove leading whitespace characters
  arg="${arg%"${arg##*[![:space:]]}"}" # remove trailing whitespace characters
  if [[ -n "$arg" ]]; then
    jq_args+=("$arg")
  fi
done < <(
  cat "$preview_cmd_args_file"
)


rc=0
command jq "${jq_args[@]}" "$query" "${inputs[@]}" >"$tmp_dir/out.tmp" 2>&1 || rc=$?

# Extract headers without any status lines (remove both ANSI-coded and plain status lines)
headers="$(grep -vE '^\x1b\[[0-9;]*m(err|null|OK)\x1b\[[0-9;]*m$|^(err|null|OK)$' "$header_file" || true)"
# Also remove any lines that become just whitespace after ANSI removal
headers="$(echo "$headers" | sed 's/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g' | grep -v '^[[:space:]]*$' || true)"
if [[ ! -f "$tmp_dir/out" ]]; then
  command mv "$tmp_dir/out.tmp" "$tmp_dir/out"
  headers="$(printf '\x1b[1;32mOK\x1b[0m\n%s\n' "$headers")"
elif [[ $rc != 0 ]]; then
  headers="$(printf '\x1b[1;31merr\x1b[0m\n%s\n' "$headers")"
  printf "\x1b[1;31m"
  command cat "$tmp_dir/out.tmp"
  printf -- "---\n\x1b[0m"
else
  # Check for null result
  cleaned_output="$(sed 's/\x1B\[[0-9;]*[mGK]//g' "$tmp_dir/out.tmp" | tr -d '\n\r')"
  if [[ "$cleaned_output" == null ]]; then
    headers="$(printf '\x1b[1;33mnull\x1b[0m\n%s\n' "$headers")"
  else
    command mv "$tmp_dir/out.tmp" "$tmp_dir/out"
    headers="$(printf '\x1b[1;32mOK\x1b[0m\n%s\n' "$headers")"
  fi
fi
printf "%s" "$headers" > "$header_file"
sync

command cat "$tmp_dir/out"
