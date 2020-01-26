zplugin ice has'pip' id-as'_pip' as"completion" \
        wait silent nocompile \
        atclone'pip completion --zsh >! _pip' \
        atpull'%atclone' pick"_pip" run-atpull \
        atload'zplugin creinstall -q .'
zplugin light zdharma/null
