# automatically copy terraform plan output
# todo this should be update to terraform once rake isn't use any more?
rake() {
  if [[ "$1" == "plan" ]]; then
    command rake "$@" | tee >(tf-plan-only | clipcopy)
  else
    command rake "$@"
  fi
}

tf-plan-only() {
  sed -r -n '/^-{72}$/,/^-{72}$/p'
}

tfc-curl() {
  local tfc_path
  tfc_path="$1"
  shift

  atlasToken="$(jq -r '.credentials["app.terraform.io"].token' "$HOME/.terraform.d/credentials.tfrc.json")"
  curl --silent --fail --show-error --header "Authorization: Bearer $atlasToken" "$@" "https://app.terraform.io/api/v2/${tfc_path#/}"
}

tfc-get-orgs() {
  tfc-curl "/organizations"
}

tfc-get-ws-by-name() {
  local orgs org_count org workspace
  orgs="$(tfc-get-orgs)"
  org_count="$(jq -r '.data|length' <<<"$orgs")"
  if (( org_count != 1 )); then
    >&2 printf "expected 1 org in account, found %d" "$org_count"
  fi
  org="$(jq -r '.data[0].attributes.name' <<<"$orgs")"

  workspace="$1"

  tfc-curl "/organizations/$org/workspaces/$workspace"
}

tfc-get-ws-id() {
  local name
  name="$1"
  if (( ${#name} >= 3 )) && [[ "${name:0:3}" == "ws-" ]]; then
    echo "$name"
    return
  fi

  tfc-get-ws-by-name "$@" | jq '.data.id' -r
}

tfc-get-state() {
  tfc-curl "/workspaces/$(tfc-get-ws-id "$1")/current-state-version" --header "content-type: application/vnd.api+json" | jq '.data.attributes."hosted-state-download-url"' -r | xargs curl --silent --fail --show-error
}

tfc-get-state-by-ws-name() {
  tfc-curl "/runs/$1/plan" --header "content-type: application/vnd.api+json" | jq '.data.attributes."log-read-url"' -r | xargs curl -s
}

tfc-get-run-plan() {
  tfc-curl "/runs/$1/plan" --header "content-type: application/vnd.api+json" | jq '.data.attributes."log-read-url"' -r | xargs curl -s
}
#/workspaces/:workspace_id/current-state-version