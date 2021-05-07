zinit ice pick'init.sh' wait silent nocompletions
zinit light b4b4r07/enhancd

zinit ice lucid wait from"gh-r" as"program" pick"bin/exa" bpick"*linux-x86_64-v*" \
    atload"
        alias ls='exa'
        alias la='exa -a'
        alias ll='exa -al --git --icons'
        alias tree='exa -T --icons'
    " \
    mv'completions/exa.zsh -> _exa' \
    atclone'pwd; \ls -la; cp man/exa* $ZPFX/share/man/man1' \
    atpull"%atclone" run-atpull
zinit light ogham/exa
