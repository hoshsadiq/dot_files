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

