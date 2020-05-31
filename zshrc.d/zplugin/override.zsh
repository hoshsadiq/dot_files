zinit ice pick'init.sh' wait"0c" silent nocompletions
zinit light b4b4r07/enhancd

zinit ice lucid wait"0" as"program" from"gh-r" \
    mv"exa* -> exa" \
    atload"
        alias ls='exa'
        alias la='exa -a'
        alias ll='exa -al --git --icons'
        alias tree='exa -T --icons'
    "
zinit light ogham/exa

zinit ice has"exa" id-as"_exa" as"completion" \
    mv'contrib/completions.zsh -> _exa' pick"_exa" \
    atclone'cp contrib/man/exa* $ZPFX/share/man/man1' \
    atpull"%atclone" run-atpull \
    atload'zinit creinstall -q .' \
    wait'1' silent nocompile
zinit light ogham/exa
