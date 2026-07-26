#!/usr/bin/env bash

set -euo pipefail

root=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

panic() {
  # shellcheck disable=SC2059
  printf >&2 "$@"
  exit 1
}

command -v jq >/dev/null 2>&1 || panic "jq is required but not installed"
command -v fzf >/dev/null 2>&1 || panic "fzf is required but not installed"

tmp_dir="$(mktemp --directory -t jqf.XXXXXXXXXX)"
trap 'command rm -rf $tmp_dir' EXIT

jq_args_file="$tmp_dir/jq_args"
jq --help | grep -Eo '\-\-?[A-Za-z0-9_-]+=?\.?' >"$jq_args_file"

inputs=()
jq_args=()
eval=0

while (( $# > 0 )); do
  case "$1" in
  --arg|--argjson|--slurpfile|--rawfile)
    jq_args+=("$1" "$2" "$3")
    shift 3
    ;;
  --indent|-f|--from-file|-L)
    jq_args+=("$1" "$2")
    shift 2
    ;;
  -L*)
      jq_args+=("$1")
      shift
    ;;
  -h | --help)
    printf >&2 "WARNING: argument '%s' ignored\n" "$1"
    shift
    ;;
  -z)
    eval=1
    shift
    ;;
  *)
    if grep -qFx -f "$jq_args_file" <<<"$1"; then
      jq_args+=("$1")
      shift
      continue
    fi
    if [[ -f "$1" ]]; then
      if [[ ! -r "$1" ]]; then
        panic "file %s is not readable" "$1"
      fi

      inputs+=("$1")
      shift
      continue
    fi
    panic "unknown arg %q" "$1"
    ;;
  esac
done

# todo this doesn't allow for streaming any more. It will block until stdin is finished.
if [[ ${#inputs[@]} -eq 0 ]]; then
  input="$tmp_dir/in"
  cat /dev/stdin >"$input"
  inputs+=("$input")
fi

preview_cmd_args_file="$tmp_dir/args"
header_file="$tmp_dir/header"
touch "$preview_cmd_args_file"
printf '%s\n' '-C' "${jq_args[@]}" >>"$preview_cmd_args_file"
command cp "$preview_cmd_args_file" "$header_file"

history_file="$HOME/.cache/fzf/.jqfhistory"
[[ ! -d $(dirname "$history_file") ]] && mkdir -p "$(dirname "$history_file")"
touch "$history_file"

query="$(
  echo -e "$(<"$header_file")\n" |
    fzf --phony \
      --no-extended \
      --disabled \
      --sync \
      --ansi \
      --tabstop=4 \
      --prompt='jq> ' \
      --history="$history_file" \
      --info=hidden \
      --header-lines=1 \
      `# having the query set is not great ux` \
      `# --query '.'` \
      --print-query \
      --preview-window='down:99%' \
      --preview "$root/preview.sh \"$tmp_dir\" {q} \"${inputs[@]}\"" \
      --bind "change:refresh-preview+reload(sleep 0.1; tr '\n' ' ' <$header_file)" \
      --bind="alt-r:execute-silent($root/update-flag.sh \"$preview_cmd_args_file\" \"$header_file\" \"-r\")+refresh-preview+reload(tr '\n' ' ' <$header_file)" \
      --bind="alt-c:execute-silent($root/update-flag.sh \"$preview_cmd_args_file\" \"$header_file\" \"-c\")+refresh-preview+reload(tr '\n' ' ' <$header_file)" \
      --bind="alt-j:execute-silent($root/update-flag.sh \"$preview_cmd_args_file\" \"$header_file\" \"-j\")+refresh-preview+reload(tr '\n' ' ' <$header_file)" \
      --bind="alt-0:execute-silent($root/update-flag.sh \"$preview_cmd_args_file\" \"$header_file\" \"-0\")+refresh-preview+reload(tr '\n' ' ' <$header_file)" \
      --bind="alt-M:execute-silent($root/update-flag.sh \"$preview_cmd_args_file\" \"$header_file\" \"-M\" \"-C\")+refresh-preview+reload(tr '\n' ' ' <$header_file)" \
      --bind="alt-C:execute-silent($root/update-flag.sh \"$preview_cmd_args_file\" \"$header_file\" \"-C\" \"-M\")+refresh-preview+reload(tr '\n' ' ' <$header_file)" \
      --bind="ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up" \
      --bind="ctrl-j:preview-down,ctrl-k:preview-up" \
      --bind="pgdn:preview-half-page-down,pgup:preview-half-page-up" \
      --bind="down:preview-down,up:preview-up"
)"

printf "%s\n" "$query"

if [[ -n "$eval" ]]; then
  while read -r arg; do jq_args+=("$arg"); done <"$preview_cmd_args_file"
  printf "\n"
  exec jq "${jq_args[@]}" "$query" "${inputs[@]}"
fi
