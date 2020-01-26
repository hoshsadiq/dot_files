zplugin ice silent wait"0" as"program" from"gh-r" atload'export FZF_DEFAULT_OPTS="--reverse --exit-0 --border --ansi"'
zplugin light 'junegunn/fzf-bin'

zplugin ice multisrc"shell/{completion,key-bindings}.zsh" \
    id-as"junegunn/fzf_completions" pick"/dev/null" \
    sbin"bin/fzf-tmux"
zplugin light junegunn/fzf

zplugin ice wait"0a" silent as"command" if'[[ -z "$commands[fzy]" ]]' \
       make"!PREFIX=$ZPFX install" atclone"cp contrib/fzy-* $ZPFX/bin/" pick"$ZPFX/bin/fzy*"
zplugin light jhawthorn/fzy
# Install fzy-using widgets
zplugin ice wait"0a" silent
zplugin light aperezdc/zsh-fzy
bindkey '\ec' fzy-cd-widget
bindkey '^T'  fzy-file-widget
