# for some reason this has to be exported here eventhough $TERM is actually populated with this value already.
# export TERM=xterm-256color

_zsh_powerlevel10k_load() {
  source "$DOT_FILES/config/zsh/p10k.zsh"

  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='$'
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=30

  unfunction _zsh_powerlevel10k_load
}

zinit ice depth=1 atload"_zsh_powerlevel10k_load"
zinit light romkatv/powerlevel10k
