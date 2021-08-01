PATH_DEBUG=false

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

path-add() {
  paths=()
  add_before=false
  for arg in "$@"; do
    if [[ "$arg" == "--before" ]]; then
      add_before=true
      continue
    fi

    dir="${arg%/}"
    if [ -d "$dir" ] && ! echo "$PATH" | grep -Eq "(^|:)$dir($|:)" && ! inArray "$dir" "${paths[@]}"; then
      paths=("$dir")
    fi
  done

  paths_sep="$(join_by ":" "${paths[@]}")"
  if [[ -z "$paths_sep" ]]; then
    [[ ${PATH_DEBUG:-false} == "true" ]] && >&2 printf "path-add: skipping empty path (args: '%s')\n" "$*"
    return
  fi

  if [[ "$add_before" == "true" ]]; then
    PATH="$paths_sep:$PATH"
    [[ ${PATH_DEBUG:-false} == "true" ]] && >&2 printf "path-add: added '%s' before\n" "$paths_sep"
  else
    PATH="$PATH:$paths_sep"
    [[ ${PATH_DEBUG:-false} == "true" ]] && >&2 printf "path-add: added '%s' after" "$paths_sep"
  fi
  PATH="$(echo "$PATH" | sed -e 's;^:\+\|:\+$;;g' -e 's;::\*;:;g')"
}

path-rm() {
    PATH="$(echo "$PATH" | sed -e "s;\(^\|:\)${1%/}\(:\|\$\);\1\2;g" -e 's;^:\|:$;;g' -e 's;::*;:;g')"
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
   $0                             Alias for '$0 show'
   $0 show                        Show the current items in the \$PATH variable in a
                                    human readable format
   $0 add ~/bin                   Add '~/bin' to the \$PATH variable
   $0 rm ~/bin                    Remove '~/bin' from the \$PATH variable

OPTIONS
  show                            Show the current contents in the \$PATH variable.
  add path [path...] [--before]   Add 'path' to the \$PATH variable. If --before is selected,
                                    the path gets added at the beginning of \$PATH, else at the end.
  rm path [path...] [--before]    Remove 'path' to the \$PATH variable. If --before is selected,
                                    the path gets added at the beginning of \$PATH, else at the end.
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

# always at the very end.
#path-add ./bin
#path-add .
