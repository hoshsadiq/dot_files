zinit ice has'pip' id-as'python-pip---zsh-completions' as"completion" \
        wait'1' silent nocompile \
        atclone'pip completion --zsh > _pip' pick"_pip" \
        atpull'%atclone' run-atpull \
        atload'zinit creinstall . &>/dev/null'
zinit light zdharma/null

zinit ice id-as"poetry---zsh-completions" as"completion" wait silent blockf \
  has'poetry' \
  atclone'poetry completions zsh >! _poetry' \
  atpull'%atclone' run-atpull \
  pick'_poetry'
zinit light zdharma/null
