#!/usr/bin/env bash

set -euo pipefail

# set -x
# echo "start at: $(date)" >&2
# exec 2> /tmp/tmux-curdir.log

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/../helpers/helpers.sh"

declare -A options
options[show-icon]='true'
options[max-depth]='2'
options[seperator]='/'
options[icon-config]='\ue5fc' # nf-custom-folder_config
options[icon-not-writable]='\uf74f' # nf-mdi-folder_lock
options[icon-home]='\uf74b' # nf-mdi-folder_account
# options[icon-git]='\ue5fb' # nf-custom-folder_git
options[icon-other]='\uf74a' # nf-mdi-folder

function join_by {
  local IFS="$1"
  shift
  echo "$*"
}

function set_config {
  for option in "${!options[@]}"; do
    options[$option]="$(get_tmux_option "@curdir-$option" -w -d "${options[$option]}")"
  done
}

function main {
  set_config

  local dir="$(tmux display-message -p -t "$1" "#{pane_current_path}")"

  local curdir="$(cd "$dir" && dirs +0)"
  set -- "$curdir"
  IFS="/" && declare -a path_array=($*)

  local length="${#path_array[@]}"
  if [[ "${options[max-depth]}" > "$length" ]]; then
    options[max-depth]="${#path_array[@]}"
  fi

  if [[ "${options[show-icon]}" ]]; then
    if [[ -n "${options[icon-config]}" && "${options[icon-config]}" != "false" ]] && [[ "$dir" == "/etc" || "$dir" == "/etc/"* ]]; then
      printf "${options[icon-config]} "
    elif [[ -n "${options[icon-not-writable]}" && "${options[icon-not-writable]}" != "false" ]] && [[ ! -w "$dir" ]]; then
      printf "${options[icon-not-writable]} "
    elif [[ -n "${options[icon-home]}" && "${options[icon-home]}" != "false" ]] && [[ "$dir" == "$HOME" || "$dir" == "$HOME/"* ]]; then
      printf "${options[icon-home]} "
    elif [[ -n "${options[icon-other]}" && "${options[icon-other]}" != "false" ]]; then
      printf "${options[icon-other]} "
    fi
  fi

  if [[ "$curdir" == "${options[seperator]}" ]]; then
    printf "${options[seperator]}"
  elif [[ "$curdir" == "~" ]]; then
    printf "~"
  else
    index=$(( $length - ${options[max-depth]} ))
    printf "$(join_by "${options[seperator]}" "${path_array[@]:$index:$length}")"
  fi
}


main "$@"
