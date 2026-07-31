PATH_DEBUG=false

# path/PATH are tied by zsh; keep unique entries so we can rely on array ops.
typeset -U path PATH

join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

inArray () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# path-add: append (or --before prepend) one or more directories to $PATH.
# Skips non-existent paths and already-present entries. Pure zsh, no forks.
path-add() {
  local dir add_before=false
  local -a paths

  for dir in "$@"; do
    if [[ "$dir" == "--before" ]]; then
      add_before=true
      continue
    fi

    dir="${dir%/}"
    [[ -d "$dir" ]] || continue
    # (Ie) = "index of exact match"; 0 means not present.
    (( ${path[(Ie)$dir]} )) && continue
    (( ${paths[(Ie)$dir]} )) && continue
    paths+=("$dir")
  done

  (( ${#paths} )) || {
    [[ ${PATH_DEBUG:-false} == "true" ]] && >&2 printf "path-add: nothing to add (args: '%s')\n" "$*"
    return
  }

  if [[ "$add_before" == "true" ]]; then
    path=("${paths[@]}" "${path[@]}")
    [[ ${PATH_DEBUG:-false} == "true" ]] && >&2 printf "path-add: prepended '%s'\n" "${(j.:.)paths}"
  else
    path=("${path[@]}" "${paths[@]}")
    [[ ${PATH_DEBUG:-false} == "true" ]] && >&2 printf "path-add: appended '%s'\n" "${(j.:.)paths}"
  fi
}

# path-rm: remove a directory from $PATH. Pure zsh.
path-rm() {
  local target="${1%/}"
  path=("${(@)path:#$target}")
}

path-show() {
    echo -e "${PATH//:/\\n}"
}

path() {
  if [[ $# == 0 ]]; then
    path-show
    return $?
  else
    action="$1"
    shift

    if [[ "$action" == "--help" ]]; then
      cat <<EOF
USAGE
  $0 [--help] [show|add|rm] [path] [path...] [--before]

EXAMPLE
   $0                                            Alias for '$0 show'
   $0 show                                       Show the current items in the \$PATH variable in a
                                                   human readable format
   $0 add ~/bin                                  Add '~/bin' to the \$PATH variable
   $0 rm ~/bin                                   Remove '~/bin' from the \$PATH variable

OPTIONS
  show                                           Show the current contents in the \$PATH variable.
  add path [path...] [--before|--ensure-first]   Add 'path' to the \$PATH variable. If --before is selected,
                                                   the path gets added at the beginning of \$PATH, else at the end.
  rm path [path...]                              Remove 'path' to the \$PATH variable.
EOF
      return 0
    elif [[ "$action" == "show" ]]; then
      path-show
      return $?
    elif [[ "$action" == "add" ]]; then
      path-add "$@"
      return $?
    elif [[ "$action" == "rm" ]]; then
      path-rm "$@"
      return $?
    fi
  fi

  path --help
  return 1
}

export WORKSPACE="$HOME/workspace/src"
export PYENV="$GOPATH/pyenv"

[[ -d "$GOPATH" ]] && path-add "$GOPATH/bin"
path-add --before "$DOT_FILES/bin"

if [[ -d "$HOME/apps/android" ]]; then
  path-add "$HOME/apps/android/platform-tools"
  path-add "$HOME/apps/android/tools/bin"
fi
[[ -n "$JAVA_HOME" ]] && path-add "$JAVA_HOME/bin"

export GOPATH="$HOME/.gopath"

# always at the very end.
#path-add ./bin
#path-add .
