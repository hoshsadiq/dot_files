ws2wsfile() {
  local ws
  ws="$1"
  if [[ $ws =~ ([a-z\-]+)_(catamorphic_dr|[a-z\-]+)_([a-z0-9\-]+)_([a-z\-]+)_([a-z0-9\-]+) ]]; then
    printf "accounts/terraform-cloud/workspaces/%s_%s/workspace" "${match[1]}" "${match[2]}"
    printf "_%s" "${match[1]}" "${match[2]}" "${match[3]}" "${match[4]}" "${match[5]}"
    printf ".tf"
  else
    >&2 "invalid workspace: %s" "$ws"
    return 1
  fi
}

ws2dir() {
  local ws
  ws="$1"
  if [[ $ws =~ ([a-z\-]+)_(catamorphic_dr|[a-z\-]+)_([a-z0-9\-]+)_([a-z\-]+)_([a-z0-9\-]+) ]]; then
    printf "accounts"
    printf "/%s" "${match[1]}" "${match[2]}" "${match[3]}" "${match[4]}" "${match[5]}"
  else
    >&2 "invalid workspace: %s" "$ws"
    return 1
  fi
}

dir2ws() {
  dir="$1"
  s=${dir//\/}
  if ((((${#dir} - ${#s}) / 1) != 5)); then
    dir="${dir//.\/}"
    dir="${dir%/}"
  fi

  awk -F/ '{print $2"_"$3"_"$4"_"$5"_"$6}' <<<"$dir"
}

tf-list-unused-vars() {
  local rc
  rc=0
  while read -r var; do
    if ! grep --no-filename --extended-regexp "\bvar\.${var}\b" ./*.tf | grep --invert-match --extended-regexp "^\s*#" >/dev/null; then
      echo '[!] Unused variable: '"${var}"
      rc=1
    fi
  done < <(grep --no-filename --invert-match --extended-regexp "^\s*#" ./*.tf | sed --quiet --regexp-extended 's/variable "([^"]+)" \{$/\1/p')

  return $rc
}

# Gets a list of all possible targets for use with the terraform `-target` flag. Useful for filtering and then subsequently running `terraform plan...`
tf-get-target-resource-paths() {
  state_resources="$(terraform state list | grep -P '^[\w\-\.]+$' | sed "s/^/ -target=/")"
  resources="$(awk -F'"' '/^resource /{print " -target="$2"."$4}' ./*.tf)"
  tf_modules="$(awk -F'"' '/^module /{print " -target=module."$2}' ./*.tf)"

  cat <<EOF | grep -v '[=\.]data\.' | sort -u
$state_resources
$resources
$tf_modules
EOF
}

