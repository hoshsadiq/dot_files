zinit ice has'kubectl' id-as'kubernetes---kubectl-completions' \
        wait silent blockf nocompletions \
        atclone'kubectl completion zsh >! kubectl-completions.zsh' \
        atpull'%atclone' run-atpull \
        pick'kubectl-completions.zsh' src'kubectl-completions.zsh' \
        atload'zinit cdreplay -q'
zinit light zdharma/null

zinit ice has'kops' id-as'kubernetes---kops-completions' \
        wait silent blockf nocompletions \
        atclone'kops completion zsh >! kops-completions.zsh' \
        atpull'%atclone' run-atpull \
        pick'kops-completions.zsh' src'kops-completions.zsh' \
        atload'zinit cdreplay -q'
zinit light zdharma/null

zinit ice has'minikube' id-as'kubernetes---minikube-completion' \
        wait silent blockf nocompletions \
        atclone'minikube completion zsh >! minikube-completions.zsh' \
        atpull'%atclone' run-atpull \
        pick'minikube-completions.zsh' src'minikube-completions.zsh' \
        atload'zinit cdreplay -q'
zinit light zdharma/null
