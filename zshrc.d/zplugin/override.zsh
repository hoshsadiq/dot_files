zplugin ice pick'init.sh' wait"0c" silent nocompletions
zplugin light b4b4r07/enhancd


zplugin ice lucid wait"0" as"program" from"gh-r" \
    mv"exa* -> exa" \
    atload"
        alias ls='exa'
        alias la='exa -a'
        alias ll='exa -al --git --icons'
        alias tree='exa -T --icons'
    "
zplugin light 'ogham/exa'

zplugin ice wait'1' lucid has"exa" as"completion" mv"contrib/completions.zsh->_exa" pick"_exa"
zplugin light ogham/exa
