if (( $+commands[terraform] )); then
  complete -o nospace -C "$(command -v terraform)" terraform
fi

# todo there's a whole bunch of completions in /usr/share/bash-completion/completions/ that may not be loaded
