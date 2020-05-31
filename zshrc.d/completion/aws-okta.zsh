zinit ice id-as"aws-okta---zsh-completions" as"completion" \
  wait silent blockf \
  has'aws-okta' \
  atclone'aws-okta completions zsh >! _aws-okta' \
  atpull'%atclone' run-atpull \
  pick'_aws-okta'
zinit light zdharma/null
