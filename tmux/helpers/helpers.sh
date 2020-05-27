#!/usr/bin/env bash

set -euo pipefail

get_tmux_option() {
	local option
	local default_value=""
	local option_value

	option="$1"
	shift

	args=("-q" "-v")
	while getopts ":gwd:" opt; do
		case "$opt" in
			d) default_value="$OPTARG" ;;
			g|w) args+=("-$opt") ;;
		esac
	done

	option_value="$(tmux show-option "${args[@]}" "$option")"
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

set_tmux_option() {
	local option="$1"
	shift
	local value="$1"
	shift

	tmux set-option -q "$@" "$option" "$value"
}

do_interpolation() {
	local interpolated="$1"
  scripts=($(find "$CURRENT_DIR/scripts" -name '*.sh'))
	# scripts=(/home/hosh/dot_files/tmux/scripts/git-status.sh)
  for script in "${scripts[@]}"; do
    basename="$(basename "$script" .sh)"
		find="#\{tmux-$basename(( (\"?#\{?\w+\}?\"?|\-\-?\w+))+)?\}"
    replace_with="#($script\1)"
    interpolated="$(echo "$interpolated" | sed -E "s@$find@$replace_with@")"
   done
	 echo "$interpolated"
}

update_tmux_option() {
	local option="$1"
	shift
	local option_value="$(get_tmux_option "$option" "$@")"
	local new_option_value="$(do_interpolation "$option_value")"

	set_tmux_option "$option" "$new_option_value" "$@"
}

is_osx() {
	[[ "$OSTYPE" == "darwin" ]]
}

is_linux() {
	[[ "$OSTYPE" == "linux-gnu" ]]
}

is_freebsd() {
	[[ "$OSTYPE" == "freebsd" ]]
}

is_cygwin() {
	[[ "$OSTYPE" == "cygwin" ]]
}

is_msys() {
	[[ "$OSTYPE" == "msys" ]]
}
