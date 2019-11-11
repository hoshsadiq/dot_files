autoload -U +X bashcompinit && bashcompinit

if (( $+commands[terraform] )); then
  complete -o nospace -C "$(which terraform)" terraform
fi
