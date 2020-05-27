manl() {
  man -k . | fzf --prompt='Man> ' | awk '{exec $1}' | xargs -r man
}

jqf() (
  local exec
  local scalars
  local positionals
  local skip
  local jq_args

  exec=""
  scalars=""
  positionals=()

  skip=""
  jq_args=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --)
      skip=1
      shift
      ;;
    *)
      [[ -n "$skip" ]] && jq_args+=("$1") && shift && continue
      [[ "$1" == "-e" ]] && exec=1 && shift && continue
      [[ "$1" == "-s" ]] && scalars=1 && shift && continue
      positionals+=("$1") && shift
      ;;
    esac
  done
  set -- "${positionals[@]}" # restore positional parameters

  if [[ -n "$1" ]]; then
    input="$1"
    [[ ! -r "$input" ]] && printf >&2 "file %s does not exist" "$input"
    shift
  else
    input="$(mktemp)"
    # shellcheck disable=SC2064
    trap "rm -f $input" EXIT
    cat /dev/stdin >"$input"
  fi

  if [[ -n "$scalars" ]]; then
    scalars="$(jq -r 'paths(scalars) | map(tostring)  | join(".") | ".\(.)"' "$input")"
  fi

  local query
  query="$(
    echo "$scalars" |
      fzf --phony \
        --prompt='jq> ' \
        --preview-window='up:90%' \
        --print-query \
        --preview "jq $(printf "%q" "$@") -C {q} $input"
  )"
  [[ -n "$exec" ]] && jq "$@" "$query" "$input" && return

  printf "%s" "$query"
)
