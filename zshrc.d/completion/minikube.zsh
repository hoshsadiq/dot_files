if (( $+commands[minikube] )); then
    local __minikube_completion_file="/tmp/minikube_completion"

    if [[ ! -f $__minikube_completion_file ]]; then
        minikube completion zsh >! $__minikube_completion_file
    fi

    [[ -f $__minikube_completion_file ]] && source $__minikube_completion_file

    unset __minikube_completion_file
fi
