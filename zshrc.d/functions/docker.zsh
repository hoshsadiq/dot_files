docker-list-tags() {
  i=0

  img="${1:-50}"
  max="${2:-50}"

  tags="[]"
  while [[ $? == 0 ]]; do
    i=$((i + 1))
    tags="$(curl -s "https://registry.hub.docker.com/v2/repositories/$img/tags/?page=$i" | jq -r --arg old_tags "$tags" '. + [."results"[]["name"]]')"
    if [[ "$(echo "$tags" | jq '. | length')" -ge "$max" ]]; then
      break
    fi
  done

  echo "$tags" | jq -r '. | @tsv' # todo actually we want to separate them at intervals
}
