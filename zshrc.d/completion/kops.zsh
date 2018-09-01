if (( $+commands[kops] )); then
    local __kops_completion_file="/tmp/kops_completion"

    if [[ ! -f $__kops_completion_file ]]; then
        kops completion zsh >! $__kops_completion_file
    fi

    [[ -f $__kops_completion_file ]] && source $__kops_completion_file

    unset __kops_completion_file
fi
