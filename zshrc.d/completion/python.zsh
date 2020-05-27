zplugin ice has'pip' id-as'python-pip---zsh-completions' as"completion" \
        wait'1' silent nocompile \
        atclone'pip completion --zsh > _pip' pick"_pip" \
        atpull'%atclone' run-atpull \
        atload'zplugin creinstall . &>/dev/null'
zplugin light zdharma/null

zplugin ice id-as"poetry---zsh-completions" as"completion" wait silent blockf \
  has'poetry' \
  atclone'poetry completions zsh >! _poetry' \
  atpull'%atclone' run-atpull \
  pick'_poetry'
zinit light zdharma/null
