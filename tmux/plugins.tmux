#!/usr/bin/env bash

set -euo pipefail

set -x
echo "start at: $(date)" >&2
exec 2> /tmp/tmux-plugins.log

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers/helpers.sh"

main() {
	update_tmux_option "status-left" -g
	update_tmux_option "status-right" -g
	update_tmux_option "pane-border-format" -gw
}

main
