#magic-enter () {
#
#  # If commands are not already set, use the defaults
#  [ -z "$MAGIC_ENTER_GIT_COMMAND" ] && MAGIC_ENTER_GIT_COMMAND="git status -u ."
#  [ -z "$MAGIC_ENTER_OTHER_COMMAND" ] && MAGIC_ENTER_OTHER_COMMAND="ls -lh ."
#
#  if [[ -z $BUFFER ]]; then
#    echo ""
#    if git rev-parse --is-inside-work-tree &>/dev/null; then
#      eval "$MAGIC_ENTER_GIT_COMMAND"
#    else
#      eval "$MAGIC_ENTER_OTHER_COMMAND"
#    fi
#    zle redisplay
#  else
#    zle accept-line
#  fi
#}
#zle -N magic-enter
#bindkey "^M" magic-enter