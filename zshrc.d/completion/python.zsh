zinit ice has'pip' id-as'python-pip---zsh-completions' as"completion" \
        wait'1' silent blockf \
        atclone'pip completion --zsh > _pip' \
        atpull'%atclone' run-atpull \
	pick"_pip"
zinit light zdharma/null

zinit ice has'poetry' id-as"poetry---zsh-completions" as"completion" \
	wait silent blockf \
	atclone'poetry completions zsh >! _poetry' \
	atpull'%atclone' run-atpull \
	pick'_poetry'
zinit light zdharma/null
