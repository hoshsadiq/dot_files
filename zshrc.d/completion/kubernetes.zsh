zplugin ice from "gh" as"completion" has'kubectl' pick'_kubectl' wait silent blockf
zplugin light nnao45/zsh-kubectl-completion

zplugin ice has'kops' id-as'kops_completion' as"null" wait silent \
        blockf nocompletions nocompile \
        atclone'kops completion zsh >! kcmpl.zsh' \
        atpull'%atclone' src"kcmpl.zsh" run-atpull \
        atload'zplugin cdreplay &>/dev/null'
zplugin light zdharma/null

zplugin ice has'minikube' id-as'minikube_completion' as"null" wait silent \
        blockf nocompletions nocompile \
        atclone'minikube completion zsh >! mkcmpl.zsh' \
        atpull'%atclone' src"mkcmpl.zsh" run-atpull \
        atload'zplugin cdreplay &>/dev/null'
zplugin light zdharma/null
