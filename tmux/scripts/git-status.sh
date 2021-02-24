#!/usr/bin/env zsh

set -euo pipefail

# set -x
# echo "start at: $(date)" >&2
# exec 2> /tmp/tmux-git-status.log

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-$0}" )" && pwd )"

source "$CURRENT_DIR/../helpers/helpers.sh"

typeset -A settings
settings[icon]='\ue725'
settings[prefix]='┤ '
settings[suffix]=' ├'
# settings[statusd-directory]='~/.gitstatusd'
settings[statusd-directory]="$HOME/.zinit/plugins/romkatv---powerlevel10k/gitstatus"

settings[icon-staged]='\uf914' # nf-mdi-plus
settings[icon-unstaged]='\uf704' # nf-mdi-exclamation
settings[icon-untracked]='\uf128' # nf-fa-question
settings[icon-stashes]='\uf9cd' # nf-mdi-star
settings[icon-ahead]='\uf55c' # nf-mdi-arrow_up
settings[icon-behind]='\uf544' # nf-mdi-arrow_down

settings[staged-count]='true'
settings[unstaged-count]='true'
settings[untracked-count]='false'
settings[stashes-count]='true'
settings[ahead-count]='true'
settings[behind-count]='true'


function update_settings {
  for key val in ${(kv)settings}; do
    settings[$key]="$(get_tmux_option "@git-status-$key" -w -d "$val")"
  done
}

function get_git_status {
  local dir
  local tmux_git_status

  [[ ! -d "${settings[statusd-directory]}" ]] && { echo "Must set @git-status-statusd-directory" && exit 1; }

  dir="$(tmux display-message -p -t "$1" "#{pane_current_path}")"

  source "${settings[statusd-directory]}/gitstatus.plugin.zsh"

  gitstatus_stop tmux && gitstatus_start tmux
  if gitstatus_query -d "$dir" tmux && [[ $VCS_STATUS_RESULT == ok-sync ]]; then
    tmux_git_status="${settings[prefix]}"

    if [[ -n "${settings[icon]}" ]]; then
      tmux_git_status+="${settings[icon]} "
    fi
    tmux_git_status+="${${VCS_STATUS_LOCAL_BRANCH:-@${VCS_STATUS_COMMIT}}//\%/%%}"

    if [[ $VCS_STATUS_COMMITS_AHEAD != "0" ]]; then
       tmux_git_status+=" ${settings[icon-ahead]}"
       [[ "${settings[ahead-count]}" == 'true' ]] && tmux_git_status+="$VCS_STATUS_COMMITS_AHEAD"
    fi

    if [[ $VCS_STATUS_COMMITS_BEHIND != "0" ]]; then
       tmux_git_status+=" ${settings[icon-behind]}"
       [[ "${settings[behind-count]}" == 'true' ]] && tmux_git_status+="$VCS_STATUS_COMMITS_BEHIND"
    fi

    if [[ $VCS_STATUS_HAS_STAGED == 1 ]]; then
       tmux_git_status+=" ${settings[icon-staged]}"
       [[ "${settings[staged-count]}" == 'true' ]] && tmux_git_status+="$VCS_STATUS_NUM_STAGED"
    fi

    if [[ $VCS_STATUS_HAS_UNSTAGED == 1 ]]; then
      tmux_git_status+=" ${settings[icon-unstaged]}"
      [[ "${settings[unstaged-count]}" == 'true' ]] && tmux_git_status+="$VCS_STATUS_NUM_UNSTAGED"
    fi

    if [[ $VCS_STATUS_HAS_UNTRACKED == 1 ]]; then
      tmux_git_status+=" ${settings[icon-untracked]}"
      [[ "${settings[untracked-count]}" == 'true' ]] && tmux_git_status+="$VCS_STATUS_NUM_UNTRACKED"
    fi

    if [[ $VCS_STATUS_STASHES != "0" ]]; then
      tmux_git_status+=" ${settings[icon-stashes]}"
      [[ "${settings[stashes-count]}" == 'true' ]] && tmux_git_status+="$VCS_STATUS_STASHES"
    fi
    tmux_git_status+="${settings[suffix]}"

    printf "%s" "${tmux_git_status}"
  fi
}

main() {
  update_settings

	get_git_status "$@"
}

main "$@"
