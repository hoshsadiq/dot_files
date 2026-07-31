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
# Walk parents in pure zsh looking for a .git entry. Skips the double `git`
# fork (~20ms on shell start when cwd is inside a repo).
_z_find_gitroot() {
  local dir=$PWD
  while [[ -n $dir && $dir != / ]]; do
    [[ -e $dir/.git ]] && { print -r -- "$dir"; return 0; }
    dir=${dir:h}
  done
  return 1
}

_z_path_add_gitroot() {
  if [[ -n "$_last_git_bin" ]]; then
    path-rm "$_last_git_bin"
    _last_git_bin=""
  fi

  local root
  if root=$(_z_find_gitroot); then
    local git_bin="$root/bin"
    [[ -d $git_bin ]] || return 0
    path-add "$git_bin"
    _last_git_bin="$git_bin"
  fi
}
add-zsh-hook -Uz chpwd _z_path_add_gitroot
_z_path_add_gitroot
