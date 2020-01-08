_z_chpwd() {
  if [[ -f "go.mod" ]]; then
    GO111MODULE=on
    export GO111MODULE
  else
    unset GO111MODULE
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook -Uz chpwd _z_chpwd
_z_chpwd
