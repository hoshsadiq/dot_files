autoload -U +X bashcompinit && bashcompinit

if (( $+commands[terraform] )); then
  complete -o nospace -C "$(command -v terraform)" terraform
fi

if (( $+commands[aws] )) && (( $+commands[aws_completer] )); then
  complete -C "$(command -v aws_completer)" aws
fi
