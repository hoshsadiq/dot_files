source "$HOME/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

zmodload -i zsh/complist
autoload -Uz compinit
compinit

# oh my zsh plugins
zplugin ice depth=1 wait silent
zplugin snippet OMZ::lib/clipboard.zsh
zplugin ice depth=1 wait silent
zplugin snippet OMZ::lib/grep.zsh
zplugin ice depth=1 wait silent
zplugin snippet OMZ::lib/spectrum.zsh
zplugin ice depth=1 wait silent
zplugin snippet OMZ::lib/termsupport.zsh

zplugin ice wait"0a" silent as"command" if'[[ -z "$commands[fzy]" ]]' \
       make"!PREFIX=$ZPFX install" atclone"cp contrib/fzy-* $ZPFX/bin/" pick"$ZPFX/bin/fzy*"
zplugin light jhawthorn/fzy
# Install fzy-using widgets
zplugin ice wait"0a" silent
zplugin light aperezdc/zsh-fzy
bindkey '\ec' fzy-cd-widget
bindkey '^T'  fzy-file-widget

#zplugin ice depth=1 wait'1' silent
#zplugin snippet OMZ::plugins/common-aliases/common-aliases.plugin.zsh
zplugin ice depth=1 wait silent
zplugin snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zplugin ice depth=1 wait silent
zplugin snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh
#zplugin ice depth=1 wait silent
zplugin snippet OMZ::plugins/globalias/globalias.plugin.zsh

zplugin ice depth=1 wait"0a" compile'{src/*.zsh,src/strategies/*}' silent atload'_zsh_autosuggest_start'
zplugin light zsh-users/zsh-autosuggestions

zplugin ice silent wait"0" as"program" from"gh-r" atload'export FZF_DEFAULT_OPTS="--reverse --exit-0 --border --ansi"'
zplugin light 'junegunn/fzf-bin'

zplugin ice wait"0b" silent
zplugin light hlissner/zsh-autopair

zplugin ice pick'init.sh' wait"0c" silent nocompletions
zplugin light b4b4r07/enhancd

zplugin ice wait"2" silent
zplugin light wfxr/forgit

zplugin ice wait"2" as"program" pick"tldr" silent
zplugin light raylee/tldr

zplugin ice lucid wait"0" as"program" from"gh-r" \
    pick"delta*/delta"
zplugin light 'dandavison/delta'

_zsh-notify-setting() {
  zstyle ':notify:*' error-title "Command failed (in #{time_elapsed} seconds)"
  zstyle ':notify:*' success-title "Command finished (in #{time_elapsed} seconds)"
}
zplugin ice wait"2" atload"_zsh-notify-setting" lucid
zplugin light marzocchi/zsh-notify

zplugin ice lucid wait"0" as"program" from"gh-r" \
    mv"exa* -> exa" \
    atload"
        alias ls='exa'
        alias la='exa -a'
        alias ll='exa -al --git --icons'
        alias tree='exa -T --icons'
    "
zplugin light 'ogham/exa'

zplugin ice depth=1 wait"0a" atload"_zsh_highlight" silent
zplugin light zdharma/fast-syntax-highlighting

# todo these need to be loaded conditionally
# zplugin snippet OMZ::plugins/osx/osx.plugin.zsh

# todo consider these, do i need it? they seem cool...
# zplugin light tj/git-extras
# zplugin load zdharma/zui
