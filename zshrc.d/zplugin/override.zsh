if (( $+commands[eza] )); then
  alias ls='eza'
  alias la='eza -a'
  alias ll='eza -al --git --icons'
  alias tree='eza -T --icons'
fi

if (( $+commands[bat] )); then
#  bat() {
#    local theme
#    theme="$(readlink "$DOT_FILES/config/alacritty/colors.yml")"
#    theme="${theme%.*}"
#    command bat --theme="$theme" "$@"
#  }

  alias cat="bat -p --paging=never"
  alias less='bat --pager "$PAGER $LESS" --style=snip,header --color=always'
fi
