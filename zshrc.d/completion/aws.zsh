if (( $+commands[aws_zsh_completer.sh] )); then
    _aws_zsh_completer_path=$(which aws_zsh_completer.sh 2>/dev/null)

    if [[ -n "$_aws_zsh_completer_path" && -x $_aws_zsh_completer_path ]]; then
        source $_aws_zsh_completer_path
    fi

    unset _aws_zsh_completer_path
fi
