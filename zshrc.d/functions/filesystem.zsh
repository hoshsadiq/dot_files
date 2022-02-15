# mkdir & cd
mkcd() {
  local args

  args=("$@")
  mkdir -p "${args[@]}"

  local foundDir
  foundDir=false
  for arg in "${args[@]}"; do
    if [[ -d "$arg" ]]; then
      if [[ "$foundDir" != "false" ]]; then
        echo 2>"Found more than 1 dir, mkcd will go into first directory"
        break
      fi
      foundDir="$arg"
    fi
  done

  cd "$foundDir" || return $?
}

force-link() {
  link="$1"

  [[ ! -L "$link" ]] && >&2 printf "file %s is not a link" "$link" && return 1

  realLocation="$(readlink "$link")"

  [[ ! -r "$realLocation" ]] && >&2 printf "file %s does not exist or is not readable" "$realLocation" && return 1

  # todo need to handle relative path links

  cp "$realLocation" "$link"
}
