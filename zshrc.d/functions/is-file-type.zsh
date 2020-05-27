is-json() {
  command -v jq >/dev/null || { >&2 printf "jq not found, install jq first\n"; return 1; }
  jq -e . "$1" >/dev/null 2>&1
}

is-javascript() {
  command -v nodejs >/dev/null || { >&2 printf "nodejs not found, install nodejs first\n"; return 1; }
  nodejs -c "$1" >/dev/null 2>&1
}
