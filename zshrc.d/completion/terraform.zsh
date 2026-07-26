# Defer terraform completion setup until after compinit runs
# bashcompinit's complete function requires compdef to be available
#__setup_terraform_completion() {
#  if (( $+commands[terraform] && ${+functions[compdef]} )); then
#    complete -o nospace -C "$(command -v terraform)" terraform 2>/dev/null || true
#    return 0
#  fi
#  return 1
#}
#
#if [[ -t 0 ]]; then
#  # Always defer to precmd hook for consistent behavior
#  # This ensures compinit has fully completed before we try to use compdef
#  __terraform_completion_initialized=0
#  __init_terraform_completion_once() {
#    if (( __terraform_completion_initialized == 0 )); then
#      if __setup_terraform_completion; then
#        __terraform_completion_initialized=1
#        add-zsh-hook -d precmd __init_terraform_completion_once
#      fi
#    fi
#  }
#  add-zsh-hook precmd __init_terraform_completion_once
#fi

# todo there's a whole bunch of completions in /usr/share/bash-completion/completions/ that may not be loaded
