docker-list-tags() {
  i=0

  img="${1:-50}"
  max="${2:-50}"

  tags="[]"
  while [[ $? == 0 ]]; do
     i=$((i+1))
     tags="$(curl -s "https://registry.hub.docker.com/v2/repositories/$img/tags/?page=$i" | jq -r --arg old_tags "$tags" '. + [."results"[]["name"]]')"
     if [[ "$(echo "$tags" | jq '. | length')" -ge "$max" ]]; then
       break
     fi
  done

  echo "$tags"  | jq -r '. | @tsv' # todo actually we want to separate them at intervals
}

shit() {
  local user args container

  user=""
  container=""

  args=()
  while [[ $# -gt 0 ]]; do
  arg="$1"
  case $arg in
      -u|--user)
      user="$2"
      shift
      shift
      ;;
      -u=)
      user="${arg#*=}"
      shift
      ;;
      -u*)
      user="${arg:2}"
      shift
      ;;
      -*)
      args+=("$arg")
      ;;
      *)
        if [[ -z $container ]]; then
          container="$arg"
        else
          args+=("$arg")
        fi
      shift
      ;;
  esac
  done

  if [[ $user == "" ]]; then
    user="$(docker inspect --format="{{ .ContainerConfig.User }}" "$container")"
  fi

  docker run -it --rm --entrypoint /bin/sh -v "${PWD}:/workdir" -u root -w /workdir "${args[@]}" "$container" -c '
command -v bash >/dev/null || {
  >&2 echo "Bash not available, installing first..."
  command -v apt-get >/dev/null && export DEBIAN_FRONTEND=noninteractive && apt-get update -q && apt-get install bash
  command -v apk >/dev/null && apk add --no-cache -q --no-progress bash
  command -v yum >/dev/null && yum install -q bash
}

if grep -qFi debian /etc/os-release; then
  echo "Setting DEBIAN_FRONTEND=noninteractive; Remember to set it in your Dockerfile if you need"
  export DEBIAN_FRONTEND=noninteractive
fi

# todo need to find additional env vars that might be needed
echo "PATH=$PATH" >> ~/.bash_profile

exec su -s /bin/sh - '"$user"' -c /bin/bash -l
'
}
