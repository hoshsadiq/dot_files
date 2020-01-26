manl() {
  man -k . | fzf --prompt='Man> ' | awk '{print $1}' | xargs -r man
}

jqf() (
  __jqf_json="$(cat)"
  export __jqf_json

  echo "$__jqf_json" | jq -r 'paths(scalars) | map(tostring)  | join(".") | ".\(.)"' \
    | fzf --prompt='jq>' --print-query --preview='echo "$__jqf_json" | jq -Cr {q}'

  unset __jqf_json
)
