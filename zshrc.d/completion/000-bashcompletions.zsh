if (( $+commands[aws] )) && (( $+commands[aws_completer] )); then
  complete -C "$(command -v aws_completer)" aws
fi

if (( $+commands[terraform] )); then
  complete -o nospace -C "$(command -v terraform)" terraform
fi

# todo there's a whole bunch of completions in /usr/share/bash-completion/completions/ that may not be loaded
