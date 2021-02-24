zinit ice id-as"aws-okta---zsh-completions" as"completion" \
  wait silent blockf \
  has'aws-okta' \
  atclone'aws-okta completions zsh >! _aws-okta' \
  atpull'%atclone' run-atpull \
  pick'_aws-okta'
zinit light zdharma/null

zinit ice id-as'saml2aws---zsh-completions' \
        wait silent blockf nocompletions \
        has'saml2aws' \
        atclone'saml2aws --completion-script-zsh >! saml2aws-completion.zsh' \
        atpull'%atclone' run-atpull \
        pick'saml2aws-completion.zsh' \
        src'saml2aws-completion.zsh' \
        atload'zinit cdreplay -q'
zinit light zdharma/null
