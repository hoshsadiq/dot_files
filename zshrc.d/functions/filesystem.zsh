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

# cdup <number>
# cds <number> of times up
# cd 3 == cd ../../..
cdup() {
  local d=""
  limit=$1
  for ((i = 1; i <= limit; i++)); do
    d="$d/.."
  done
  d=$(echo $d | sed 's/^\///')
  if [[ -z "$d" ]]; then
    d=..
  fi
  cd $d || return $?
}
