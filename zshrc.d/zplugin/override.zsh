zinit ice pick'init.sh' wait silent nocompletions
zinit light b4b4r07/enhancd

_zsh_setup_exa_aliases() {
  alias ls='exa'
  alias la='exa -a'
  alias ll='exa -al --git --icons'
  alias tree='exa -T --icons'

  unfunction _zsh_setup_exa_aliases
}

_zsh_setup_exa_clone() {
  cp -vf completions/exa.zsh _exa
  mkdir -p "$ZPFX/share/man/man1" "$ZPFX/share/man/man5"

  cp -vf man/*.1 "$ZPFX/share/man/man1"
  cp -vf man/*.5 "$ZPFX/share/man/man5"

  zicompinit
  zicdreplay

  unfunction _zsh_setup_exa_clone
}

zinit lucid wait light-mode as"program" from"gh-r" bpick"*linux-x86_64-v*" for \
  atclone'_zsh_setup_exa_clone' \
  atpull"%atclone" \
  atload'_zsh_setup_exa_aliases' \
  pick"bin/exa" \
  @ogham/exa

_zsh_setup_bat_aliases() {
  bat() {
    local theme
    theme="$(readlink "$DOT_FILES/config/alacritty/colors.yml")"
    theme="${theme%.*}"
    command bat --theme="$theme" "$@"
  }

  alias cat="bat -p --paging=never"
  alias less='bat --pager "$PAGER $LESS" --style=snip,header --color=always'

  unfunction _zsh_setup_bat_aliases
}

_zsh_setup_bat_extras() {
  #alias man=batman
  true
}

zinit lucid wait light-mode as"program" from"gh-r" for \
  atclone'cp -vf bat*/autocomplete/bat.zsh _bat; cp -vf bat*/bat.1 $ZPFX/share/man/man1' atpull"%atclone" atload'_zsh_setup_bat_aliases' pick"bat*/bat" @sharkdp/bat \
  pick"bin/*" atclone'cp -vf man/* $ZPFX/share/man/man1' atpull"%atclone" atload'_zsh_setup_bat_extras' @eth-p/bat-extras \
  atclone'cp -vf ripgrep*/complete/_rg -> _rg; cp -vf ripgrep*/doc/rg.1 $ZPFX/share/man/man1' atpull"%atclone" pick"ripgrep*/rg" @BurntSushi/ripgrep \
	pick'ripgrep_all*/rga*' @phiresky/ripgrep-all \
  atclone'cp -vf fd*/autocomplete/_fd _fd; cp -vf fd*/fd.1 $ZPFX/share/man/man1' atpull'%atclone' mv'fd* -> fd' bpick'*x86_64*linux*.tar.gz' pick"fd/fd" @sharkdp/fd
