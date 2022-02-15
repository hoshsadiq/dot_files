zinit lucid wait light-mode blockf nocompletions nocompile atpull'%atclone' run-atpull atload'zinit cdreplay -q' for \
  has'kubectl' id-as'kubernetes---kubectl-completions' atclone'kubectl completion zsh >! kubectl-completions.zsh' pick'kubectl-completions.zsh' src'kubectl-completions.zsh' @zdharma-continuum/null \
  has'kops' id-as'kubernetes---kops-completions' atclone'kops completion zsh >! kops-completions.zsh' pick'kops-completions.zsh' src'kops-completions.zsh' @zdharma-continuum/null \
  has'minikube' id-as'kubernetes---minikube-completion' atclone'minikube completion zsh >! minikube-completions.zsh' pick'minikube-completions.zsh' src'minikube-completions.zsh' @zdharma-continuum/null \
  has'kompose' id-as'kubernetes---kompose-completion' atclone'kompose completion zsh >! kompose-completions.zsh' pick'kompose-completions.zsh' src'kompose-completions.zsh' @zdharma-continuum/null

zinit ice wait='2' lucid pick'/dev/null' sbin='kubectx' sbin='kubens' \
  atclone='
    mv completion/kubectx.zsh _kubectx;
    mv completion/kubens.zsh _kubens;
  ' \
  atpull='%atclone' run-atpull
zinit light ahmetb/kubectx

zinit ice haspodman id-as'podman---completions' \
        wait silent blockf nocompile \
        atinit"zinit cdreplay -q" \
        atclone'podman completion zsh >! _podman' \
        atpull'%atclone' run-atpull
zinit light zdharma-continuum/null
