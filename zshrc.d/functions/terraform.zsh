# automatically copy terraform plan output
# todo this should be update to terraform once rake isn't use any more?
rake() {
  if [[ "$1" == "plan" ]]; then
    command rake "$@" | tee >(tf-plan-only | clipcopy)
  else
    command rake "$@"
  fi
}

__tfc_api_prefix="https://app.terraform.io/api/v2"

tf-plan-only() {
  sed -r -n '/^-{72}$/,/^-{72}$/p'
}

tf-atlas-token() {
  local credentials_file
  credentials_file="$HOME/.terraform.d/credentials.tfrc.json"
  [[ -r "$credentials_file" ]] || {
    printf >&2 "Unable to locate terraform credentials file. Make sure you run terraform login first!"
    return 1
  }
  jq -r '.credentials["app.terraform.io"].token' "$credentials_file"
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

tfc-curl() {
  local tfc_path
  tfc_path="$1"
  shift

  curl --silent --fail --show-error --header "Authorization: Bearer $(tf-atlas-token)" "$@" "https://app.terraform.io/api/v2/${tfc_path#/}"
}

tfc-get-first-org() {
  local orgs org_count org workspace
  orgs="$(tfc-get-orgs)"
  org_count="$(jq -r '.data|length' <<<"$orgs")"
  if ((org_count != 1)); then
    printf >&2 "expected 1 org in account, found %d" "$org_count"
  fi
  jq -r '.data[0].attributes.name' <<<"$orgs"
}

tfc-get-orgs() {
  tfc-curl "/organizations"
}

tfc-get-workspaces() {
  all_workspaces=""
  url_path="/organizations/$(tfc-get-first-org)/workspaces?page%5Dsize=100"
  while true; do
    workspaces="$(tfc-curl "$url_path")"
    all_workspaces="$(jq -s '.[0] + .[1]' <<<"$all_workspaces"$'\n'"$(jq .data <<<"$workspaces")")"

    if [[ "$(jq -r .links.next <<<"$workspaces")" == "null" ]]; then
      jq -s '{data: .[0], links: .[1].links, meta: .[1].meta}' <<<"$all_workspaces"$'\n'"$workspaces"
      break
    fi

    next_link="$(jq -r .links.next <<<"$workspaces")"
    if [[ ${next_link:0:${#__tfc_api_prefix}} != "$__tfc_api_prefix" ]]; then
      printf >&2 "Failed to retrieve next link, expected it to be prefixed with %s but was not" "$__tfc_api_prefix"
      return 1
    fi

    url_path="${next_link:${#__tfc_api_prefix}}"
  done
}

tfc-get-ws-by-name() {
  local org workspace
  org="$(tfc-get-first-org)"
  workspace="$1"

  tfc-curl "/organizations/$org/workspaces/$workspace"
}

tfc-get-ws-teams() {
  local all_teams team

  all_teams=""
  while read -r team_id team_access_id; do
    team="$(tfc-curl "/teams/$team_id")"
    all_teams="$(jq -s '.[0] + .[1]' <<<"$all_teams"$'\n'"$(jq --arg team_access_id "$team_access_id" '[.data + {team_access_id: $team_access_id}]' <<<"$team")")"
  done < <(tfc-get-team-access "$1" | jq '.data[] | [.relationships.team.data.id, .id] | @tsv' -r)

  jq '{data: .}' <<<"$all_teams"
}

tfc-get-team-access() {
  tfc-curl "/team-workspaces?filter%5Bworkspace%5D%5Bid%5D=$(tfc-get-ws-id "$1")"
}

tfc-get-ws-notification-configurations() {
  tfc-curl "/workspaces/$(tfc-get-ws-id "$1")/notification-configurations"
}

tfc-get-ws-vars() {
  tfc-curl "/workspaces/$(tfc-get-ws-id "$1")/vars"
}

tfc-get-ws-id() {
  local name
  name="$1"
  if ((${#name} >= 3)) && [[ "${name:0:3}" == "ws-" ]]; then
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

tfc-get-run() {
  tfc-curl "/runs/$1"
}

tfc-get-run-plan() {
  tfc-curl "/runs/$1/plan" --header "content-type: application/vnd.api+json" | jq '.data.attributes."log-read-url"' -r | xargs curl -s
}

tfc-create-run() {
  local workspace_id run_message

  workspace_id="$(tfc-get-ws-id "$1")"
  run_message="${2:-Run triggered from CLI via API}"

  payload="$(
    cat <<JSON | jq --arg run_message "$run_message" --arg workspace_id "$workspace_id" '.data.attributes.message=$run_message | .data.relationships.workspace.data.id=$workspace_id'
{
  "data": {
    "attributes": {
    },
    "type":"runs",
    "relationships": {
      "workspace": {
        "data": {
          "type": "workspaces"
        }
      }
    }
  }
}
JSON
  )"

  tfc-curl \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data "$payload" \
    https://app.terraform.io/api/v2/runs
}
