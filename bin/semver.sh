#!/usr/bin/env bash

set -euo pipefail

declare prefix
declare -i major minor patch
declare suffix

bump() {
  type="$1"
  case $type in
  major) major=$((major + 1)); minor=0; patch=0 ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  patch) patch=$((patch + 1)) ;;
  esac
  printf "%s%d.%d.%d%s" "$prefix" "$major" "$minor" "$patch" "$suffix"
}

main() {
  declare action="$1" version="$2"
  shift 2

  if [[ $version =~ (v)?([0-9]+)\.([0-9]+)\.([0-9]+)(.*) ]]; then
    prefix="${BASH_REMATCH[1]}"
    major="${BASH_REMATCH[2]}"
    minor="${BASH_REMATCH[3]}"
    patch="${BASH_REMATCH[4]}"
    suffix="${BASH_REMATCH[5]}"
  fi

  "$action" "$@"
}

main "$@"
