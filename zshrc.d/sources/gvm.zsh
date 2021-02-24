# shellcheck disable=SC1090
[[ -e $HOME/.gvm/scripts/gvm ]] && source "$HOME/.gvm/scripts/gvm"

gvm_post_use() {
  if command -v go >/dev/null; then
    zinit ice as"completion" wait silent blockf
    zinit snippet https://github.com/zsh-users/zsh-completions/blob/master/src/_golang
  fi
}

functions[gvm]="${functions[gvm]}
    ${functions[gvm_post_use]}"
