alias history='fc -t "%d/%m/%Y %H:%M:%S" -l 1'

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"

HISTSIZE=1200000  # Larger than $SAVEHIST for HIST_EXPIRE_DUPS_FIRST to work
# shellcheck disable=SC2034
SAVEHIST=1000000

## History command configuration
setopt bang_hist              # Treat the '!' character specially during expansion.
setopt extended_history       # Write the history file in the ":start:elapsed;command" format.
setopt inc_append_history     # Write to the history file immediately, not when the shell exits.
setopt share_history          # Share history between all sessions.
setopt hist_expire_dups_first # Expire duplicate entries first when trimming history.
setopt hist_ignore_dups       # Don't record an entry that was just recorded again.
setopt hist_ignore_all_dups   # Delete old recorded entry if new entry is a duplicate.
setopt hist_find_no_dups      # Do not display a line previously found.
setopt hist_ignore_space      # Don't record an entry starting with a space.
setopt hist_save_no_dups      # Don't write duplicate entries in the history file.
setopt hist_reduce_blanks     # Remove superfluous blanks before recording entry.
setopt hist_verify            # Don't execute immediately upon history expansion.
setopt hist_beep              # Beep when accessing nonexistent history.

bindkey -r '^[OA'
bindkey -r '^[OB'
function __bind_history_keys() {
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down

  unfunction __bind_history_keys
}

zinit ice depth=1 wait silent
zinit light zdharma-continuum/history-search-multi-word

zinit ice depth=1 silent
zinit snippet OMZ::lib/history.zsh

zinit ice wait depth=1 silent atload'__bind_history_keys'
zinit light zsh-users/zsh-history-substring-search

function clear-scrollback-buffer {
  # clear screen
  clear
  # clear buffer. The following sequence code is available for xterm.
  printf '\e[3J'
  # .reset-prompt: bypass the zsh-syntax-highlighting wrapper
  # https://github.com/sorin-ionescu/prezto/issues/1026
  # https://github.com/zsh-users/zsh-autosuggestions/issues/107#issuecomment-183824034
  # -R: redisplay the prompt to avoid old prompts being eaten up
  # https://github.com/Powerlevel9k/powerlevel9k/pull/1176#discussion_r299303453
  zle .reset-prompt && zle -R
}

# todo what's a good shortcut for this?
#zle -N clear-scrollback-buffer
#bindkey '^L' clear-scrollback-buffer

_zshaddhistory_ignore_command_escape() {
  quoted_string="${1//\\//\\\\}"
  for c in \[ \] \( \) \. \^ \$ \? \* \+ \ ; do
   quoted_string=${quoted_string//"$c"/"\\$c"}
  done

  printf "%s" "$quoted_string"
}

function _zshaddhistory_ignore_command {
	emulate -L zsh
  # shellcheck disable=SC2154
	local -r line="${(L)1%%$'\n'}"

	local show_msg msg_prefix msg_suffix
	local except_show_msg except_msg_prefix except_msg_suffix

	show_msg="${HISTIGNORE_SHOW_MSG:-true}"
	msg_prefix="${HISTIGNORE_MSG_PREFIX:-\033[94m \uf12a histignore: }"
	msg_suffix="${HISTIGNORE_MSG_SUFFIX:-\033[0m}"

	except_show_msg="${HISTIGNORE_EXCEPT_MSG:-$msg}"
	except_msg_prefix="${HISTIGNORE_EXCEPT_MSG_PREFIX:-$msg_prefix}"
	except_msg_suffix="${HISTIGNORE_EXCEPT_MSG_SUFFIX:-$msg_suffix}"

	ignore_files=("${DOT_FILES}/config/history/histignore" "$HOME/.histignore")

  exceptions=()
  ignores=()
  for ignore_file in "${ignore_files[@]}"; do
    [[ ! -r "$ignore_file" ]] && continue

    while read -r regex; do
      # shellcheck disable=SC2154
      regex="${(L)regex}"

      [[ "${regex}" == "" || "${regex:0:1}" == "#" ]] && continue

      [[ "${regex:0:5}" == "!cmd:" ]] && exceptions+=("^$(_zshaddhistory_ignore_command_escape "${regex:5}") ") && continue
      [[ "${regex:0:1}" == "!" ]]     && exceptions+=("${regex:1}") && continue

      [[ "${regex:0:4}" == "cmd:" ]]  && ignores+=("^$(_zshaddhistory_ignore_command_escape "${regex:4}") ") && continue
                                         ignores+=("${regex}")
    done < "$ignore_file"
  done

  if [[ "${#exceptions[@]}" -gt "0" ]]; then
    for exception in "${exceptions[@]}"; do
      if [[ "$line" =~ $exception ]]; then
        [[ "$except_show_msg" == "true" && -n "$line" ]] && >&2 printf "%b'%b' saved due to exception '%b'%b\n" "$except_msg_prefix" "$line" "$exception" "$except_msg_suffix"
        return 0
      fi
    done
  fi

  if [[ "${#ignores[@]}" -gt "0" ]]; then
    for ignore in "${ignores[@]}"; do
      if [[ "$line" =~ $ignore ]]; then
        [[ "$show_msg" == "true" && -n "$line" ]] && >&2 printf "%b'%b' ignored due to rule '%b'%b\n" "$msg_prefix" "$line" "$ignore" "$msg_suffix"
        return 1
      fi
    done
  fi

  return 0
}

add-zsh-hook zshaddhistory _zshaddhistory_ignore_command
