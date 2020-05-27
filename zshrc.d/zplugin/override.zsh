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
zplugin light ogham/exa

zplugin ice has"exa" id-as"_exa" as"completion" \
    mv'contrib/completions.zsh -> _exa' pick"_exa" \
    atclone'cp contrib/man/exa* $ZPFX/share/man/man1' \
    atpull"%atclone" run-atpull \
    atload'zplugin creinstall -q .' \
    wait'1' silent nocompile
zplugin light ogham/exa
