_zsh_setup_bat_aliases() {
  alias cat="bat -p --paging=never"
  alias less='bat --pager "$PAGER $LESS" --style=snip,header --color=always'
}

zinit ice lucid wait"0" as"program" from"gh-r" \
    pick"bat*/bat" atload'_zsh_setup_bat_aliases'
zinit light 'sharkdp/bat'
