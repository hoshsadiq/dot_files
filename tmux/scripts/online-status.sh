#!/usr/bin/env bash

set -euo pipefail

# set -x
# echo "start at: $(date)" >&2
# exec 2> /tmp/tmux-online-status.log

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/../helpers/helpers.sh"

declare -A options
options[online-icon]='\uf817'
options[online-style]='fg=colour22,bg=white'
options[offline-icon]='\uf818'
options[offline-style]='fg=colour124,bg=white'
options[ping-timeout]='1'
options[ping-route]='www.google.com'

function update_options {
  for option in "${!options[@]}"; do
    options[$option]="$(get_tmux_option "@status-$option" -w -d "${options[$option]}")"
  done
}

is-online() {
  local flags=()

	if is_osx || is_freebsd; then
		flags+=("-t")
	else
    flags+=("-w")
	fi
  flags+=("${options[ping-timeout]}")

	if is_cygwin; then
    flags+=("-n")
	else
    flags+=("-c")
	fi
  flags+=("1")

  flags+=("${options[ping-route]}")

	ping "${flags[@]}" &>/dev/null
}

main() {
  update_options

	if is-online; then
		printf "#[${options[online-style]}] ${options[online-icon]} "
	else
		printf "#[${options[offline-style]}] ${options[offline-icon]} "
	fi
}
# main
