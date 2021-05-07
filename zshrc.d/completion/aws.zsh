if (( $+commands[aws] )) && (( $+commands[aws_completer] )); then
  complete -C "$(command -v aws_completer)" aws
fi

zinit ice id-as'saml2aws---zsh-completions' \
        wait silent blockf nocompletions \
        has'saml2aws' \
        atclone'saml2aws --completion-script-zsh >! saml2aws-completion.zsh' \
        atpull'%atclone' run-atpull \
        pick'saml2aws-completion.zsh' \
        src'saml2aws-completion.zsh' \
        atload'zinit cdreplay -q'
zinit light zdharma/null
