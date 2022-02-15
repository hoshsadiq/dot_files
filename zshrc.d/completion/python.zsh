zinit ice has'pip' id-as'python-pip---zsh-completions' as"completion" \
        wait silent blockf nocompile \
        atclone'pip completion --zsh > _pip' \
        atpull'%atclone' run-atpull \
        atinit"zinit cdreplay -q" \
        pick"_pip"
zinit light zdharma-continuum/null

zinit ice haspoetry id-as"poetry---zsh-completions" as"completion" \
        wait silent blockf nocompile \
        atclone'poetry completions zsh >! _poetry' \
        atpull'%atclone' run-atpull \
        atinit"zinit cdreplay -q" \
        pick'_poetry'
zinit light zdharma-continuum/null
