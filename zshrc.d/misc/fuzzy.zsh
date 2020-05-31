zinit ice silent wait"0" as"program" from"gh-r" atload'export FZF_DEFAULT_OPTS="--reverse --exit-0 --border --ansi"'
zinit light 'junegunn/fzf-bin'

zinit ice multisrc"shell/{completion,key-bindings}.zsh" \
    id-as"junegunn/fzf_completions" pick"/dev/null" \
    sbin"bin/fzf-tmux" silent
zinit light junegunn/fzf

zinit ice pick"fzf-tmux" as"program" silent
zinit snippet https://github.com/junegunn/fzf/blob/master/bin/fzf-tmux

zinit ice wait"0a" silent as"command" if'[[ -z "$commands[fzy]" ]]' \
       make"!PREFIX=$ZPFX install" atclone"cp contrib/fzy-* $ZPFX/bin/" pick"$ZPFX/bin/fzy*"
zinit light jhawthorn/fzy
# Install fzy-using widgets
zinit ice wait"0a" silent
zinit light aperezdc/zsh-fzy
bindkey '\ec' fzy-cd-widget
bindkey '^T'  fzy-file-widget
