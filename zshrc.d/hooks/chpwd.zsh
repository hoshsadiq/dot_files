autoload -Uz add-zsh-hook

_z_chpwd() {
  if [[ -f "go.mod" ]]; then
    GO111MODULE=on
    export GO111MODULE
  else
    unset GO111MODULE
  fi
}
add-zsh-hook -Uz chpwd _z_chpwd
_z_chpwd

_last_git_bin=""
_z_path_add_gitroot() {
  if [[ "$_last_git_bin" != "" ]]; then
    rmpath "$_last_git_bin"
    _last_git_bin=""
  fi

  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]; then
    git_bin="$(git rev-parse --show-toplevel)/bin"
    addpath "$git_bin" after
    _last_git_bin="$git_bin"
  fi
}
add-zsh-hook -Uz chpwd _z_path_add_gitroot
_z_path_add_gitroot
