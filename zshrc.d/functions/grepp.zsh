# note this function doesn't do a proper check on the arguments
# it simply assumes all existing files and dirs are to be searched, and everything else is a grep arg
grepp() {
  grepArgs=()
  files=()
  dirs=()
  for arg in "$@"; do
    if [[ -f "$arg" ]]; then
      files+=("$arg")
    elif [[ -d "$arg" ]]; then
      dirs+=("$arg")
    else
      grepArgs+=("$arg")
    fi
  done

  (( ${#files[@]} > 0 )) && printf '%s\0' "${files[@]}" | xargs -0 -P 4 -n 1000 grep "${grepArgs[@]}"
  (( ${#dirs[@]} > 0 )) && find "${dirs[@]}" -type f -print0 | xargs -0 -P 4 -n 1000 grep "${grepArgs[@]}"
}
