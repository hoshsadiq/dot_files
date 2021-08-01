if (( $+commands[aws] )) && (( $+commands[aws_completer] )); then
  complete -C "$(command -v aws_completer)" aws
fi

zinit for \
  light-mode from'gh-r' as'program' wait silent \
      atclone'./saml2aws --completion-script-zsh > _saml2aws' \
      atpull'%atclone' run-atpull Versent/saml2aws
