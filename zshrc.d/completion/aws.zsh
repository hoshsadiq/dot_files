if (( $+commands[aws] )) && (( $+commands[aws_completer] )); then
  complete -C "$(command -v aws_completer)" aws
  zicompinit
  zicdreplay
fi
