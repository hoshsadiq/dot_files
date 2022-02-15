# for some reason this has to be exported here eventhough $TERM is actually populated with this value already.
# export TERM=xterm-256color

_zsh_powerlevel10k_load() {
  source "$DOT_FILES/config/zsh/p10k.zsh"

  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='$'
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=30

  ##########[ pritunl: pritunl connection status, linux only (https://nordvpn.com/) ]###########
  # NordVPN connection indicator color.
  typeset -g POWERLEVEL9K_PRITUNL_DISCONNECTED_FOREGROUND=red
  typeset -g POWERLEVEL9K_PRITUNL_{CONNECTING,DISCONNECTING}_FOREGROUND=yellow
  typeset -g POWERLEVEL9K_PRITUNL_FOREGROUND=green
  typeset -g POWERLEVEL9K_PRITUNL_{DISCONNECTED,CONNECTING,DISCONNECTING,CONNECTED}_VISUAL_IDENTIFIER_EXPANSION=$'\Uf983'

  # Custom icon.
  # typeset -g POWERLEVEL9K_PRITUNL_VISUAL_IDENTIFIER_EXPANSION='⭐'


  unfunction _zsh_powerlevel10k_load
}

zinit ice depth=1 atload"_zsh_powerlevel10k_load"
zinit light romkatv/powerlevel10k
