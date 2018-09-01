if (( $+commands[kubectl] )); then
    local __kubectl_completion_file="/tmp/kubectl_completion"

    if [[ ! -f $__kubectl_completion_file ]]; then
        kubectl completion zsh >! $__kubectl_completion_file
    fi

    [[ -f $__kubectl_completion_file ]] && source $__kubectl_completion_file

    unset __kubectl_completion_file
fi
