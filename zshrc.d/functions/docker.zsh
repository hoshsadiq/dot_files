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

# docker() — adds `docker compose inspect <service>...`, which compose v2 does
# not ship. Services are resolved to their container(s) — running or not — and
# handed to `docker inspect`:
#
#   docker inspect $(docker compose ps -a -q <service>)
#
# Globals are forwarded: docker globals before `compose` (-c/--context, -H/--host,
# ...) and compose globals before `inspect` (-f/--file, -p/--project-name, ...).
# Arguments after `inspect` are `docker inspect` arguments, in any position:
#
#   docker compose inspect postgres
#   docker compose inspect -f '{{.State.Status}}' postgres
#   docker -c sumin compose -p test inspect db
#
# Anything that isn't `docker ... compose ... inspect` passes through untouched.
docker() {
  local -i ci=${argv[(i)compose]} ii=${argv[(i)inspect]}
  if (( ci > $# || ii > $# || ii <= ci )); then
    command docker "$@"
    return
  fi

  local -a docker_pre=( "${(@)argv[1,ci-1]}" )
  local -a compose_pre=( "${(@)argv[ci+1,ii-1]}" )

  local -a inspect_opts services
  local a
  set -- "${(@)argv[ii+1,-1]}"
  while (( $# )); do
    a="$1"
    shift
    case $a in
    -f | --format | --type)
      inspect_opts+=("$a" "${1:-}")
      shift
      ;;
    -f=* | --format=* | --type=* | -s | --size)
      inspect_opts+=("$a")
      ;;
    -h | --help)
      command docker inspect --help | sed 's/docker inspect/docker compose inspect/g'
      return 0
      ;;
    -*)
      print -u2 "docker compose inspect: unknown option '$a'"
      print -u2 "$(command docker inspect --help | sed -n '1s/docker inspect/docker compose inspect/p')"
      return 2
      ;;
    *)
      services+=("$a")
      ;;
    esac
  done

  if (( ${#services} == 0 )); then
    print -u2 "$(command docker inspect --help | sed -n '1s/docker inspect/docker compose inspect/p')"
    return 2
  fi

  local -a ids
  local s
  for s in "${services[@]}"; do
    ids+=( "${(@f)$(command docker "${docker_pre[@]}" compose "${compose_pre[@]}" ps -a -q "$s" 2>/dev/null)}" )
  done
  ids=( "${(@)ids:#}" )
  if (( ${#ids} == 0 )); then
    print -u2 "docker compose inspect: no container for service(s): ${services[*]}"
    return 1
  fi

  command docker "${docker_pre[@]}" inspect "${inspect_opts[@]}" "${ids[@]}"
}
