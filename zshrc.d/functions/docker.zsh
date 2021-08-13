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

# todo maybe utilise: https://github.com/LEI/porcelain/blob/master/porcelain.sh
_shit_run_get_bash_profile() {
  local bashHistoryFile
  bashHistoryFile="$1"

  cat <<'EOF'
function __fastgit_ps1 () {
    local headfile head branch status
    local dir="$PWD"

    while [ -n "$dir" ]; do
        if [ -e "$dir/.git/HEAD" ]; then
            headfile="$dir/.git/HEAD"
            break
        fi
        dir="${dir%/*}"
    done

    if [ -e "$headfile" ]; then
        read -r head < "$headfile" || return
        case "$head" in
            ref:*) branch="${head#*/}"; branch="${branch#*/}" ;;
            "") branch="" ;;
            *) branch="${head:0:7}" ;;
        esac
    fi

    if [ -z "$branch" ]; then
        return 0
    fi

    # modified from https://github.com/jethrokuan/git_porcelain/blob/master/functions/git_porcelain.fish
    if command -v git >/dev/null; then
      status="$(git status --porcelain 2>/dev/null | \
                    awk "
                      /^A[MCDR ]/                  { sa++ }
                      /^M[ACDRM ]/ || /^[ACDRM ]M/ { sm++ }
                      /^D[AMCR ]/ || /^[AMCR ]D/   { sd++ }
                      /^R[AMCD ]/                  { sr++ }
                      /^C[AMDR ]/                  { sc++ }
                      /^\?\?/                      { uu++ }
                      END {
                        if (sa > 0) { printf(\" %dA\", sa); }
                        if (sm > 0) { printf(\" %dM\", sm); }
                        if (sd > 0) { printf(\" %dD\", sd); }
                        if (sr > 0) { printf(\" %dR\", sr); }
                        if (sc > 0) { printf(\" %dC\", sc); }
                        if (su > 0) { printf(\" %dU\", su); }
                      }"
                )"
    else
      status=""
    fi

    if [[ -z "$1" ]]; then
        printf "(%s%s) " "$branch" "$status"
    else
        printf "$1" "$branch" "$status"
    fi
}

shopt -s histappend                                       # Append to the history file, do not overwrite it
shopt -s cmdhist                                          # Save multi-line commands as one command
PROMPT_COMMAND="history -a"                               # Record each line as it gets issued
HISTSIZE=500000                                           # Huge history. Does not appear to slow things down, so why not?
HISTFILESIZE=100000
HISTCONTROL="erasedups:ignoreboth"                        # Avoid duplicate entries
HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"           # Do not record some commands
HISTTIMEFORMAT="%F %T "                                   # Use standard ISO 8601 timestamp
EOF

cat <<EOF
HISTFILE=${bashHistoryFile}
EOF

cat <<'EOF'
shopt -s autocd 2> /dev/null                              # Prepend cd to directory names automatically
shopt -s dirspell 2> /dev/null                            # Correct spelling errors during tab-completion
shopt -s cdspell 2> /dev/null                             # Correct spelling errors in arguments supplied to cd

PROMPT_DIRTRIM="3"

PS1=""
for pkgMan in apt-get apk yum microdnf; do
  if command -v $pkgMan >/dev/null; then
    PS1="$PS1\[\e[32m\](\[\e[m\]\[\e[33m\]$pkgMan\[\e[m\]\[\e[32m\])\[\e[m\] "
  fi
done
if [[ -z $PS1 ]]; then
  PS1="$PS1\[\e[32m\](\[\e[m\]\[\e[33m\]???\[\e[m\]\[\e[32m\])\[\e[m\] "
fi
PS1="$PS1\[\e[32m\][\[\e[m\]"
PS1="$PS1\[\e[31m\]\u\[\e[m\]"
PS1="$PS1\[\e[32m\]:\[\e[m\]"
PS1="$PS1\[\e[36m\]\w\[\e[m\]"
PS1="$PS1\$(__fastgit_ps1 \"\[\e[32m\]@\[\e[m\]\[\e[01;32m\]%s%s\[\e[m\]\")"
PS1="$PS1\[\e[32m\]]\[\e[m\]"
PS1="$PS1\[\e[32m\]\\$\[\e[m\] "
EOF
}


_shit_run_script() {
  local user user_gid user_uid bashHistoryFile
  user="$1"
  bashHistoryFile="$2"

  user_uid="$(id -u)"
  user_gid="$(id -g)"

  # language=shell
  cat <<EOF
[ ! -f /.dockerenv ] && >&2 printf "Must be run inside docker" && return 1

set -eu

. /etc/os-release

packages="sudo neovim"
command -v bash >/dev/null || packages="\$packages bash"

if command -v apt-get >/dev/null; then
  echo "\e[33mSetting DEBIAN_FRONTEND=noninteractive; Remember to set it in your Dockerfile if you need.\e[m"
  export DEBIAN_FRONTEND=noninteractive
fi

command -v microdnf >/dev/null && packages="\${packages/neovim/vim}"
>&2 echo "installing packages '\$packages' first..."
{
  command -v apt-get >/dev/null && apt-get update -qq && apt-get install -qq -y \$packages
  command -v apk >/dev/null && apk add --no-cache -q --no-progress \$packages
  command -v yum >/dev/null && yum install -q \$packages
  command -v microdnf >/dev/null && microdnf install \$packages >/dev/null 2>&1
} 2>&1 | tee /tmp/container-setup.log

env | egrep -v '^(HOME=|USER=|MAIL=|LC_ALL=|LS_COLORS=|LANG=|HOSTNAME=|PWD=|TERM=|SHLVL=|LANGUAGE=|_=)' >> /etc/environment
if command -v nvim >/dev/null; then
  ln -fs \$(command -v nvim) /usr/bin/vim
  ln -fs \$(command -v nvim) /usr/bin/vi
fi

{
  # todo this might not work for non-alpine instances
  addgroup --gid ${user_gid} ${USER}
  adduser --uid ${user_uid} --ingroup $(awk -F: "\$3 == ${user_gid}{print \$1}" /etc/group) --home /home/${USER} --gecos '' --disabled-password ${USER}
  echo "${USER} ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}
} 2>&1 | tee a /tmp/container-setup.log

echo '$(_shit_run_get_bash_profile "$bashHistoryFile")' >> "\$(getent passwd root | cut -d: -f 6)/.bash_profile"
echo '$(_shit_run_get_bash_profile "$bashHistoryFile")' >> "\$(getent passwd ${USER} | cut -d: -f 6)/.bash_profile"
if [ $user != ${USER} ] && [ $user != root ]; then
echo '$(_shit_run_get_bash_profile "$bashHistoryFile")' >> "\$(getent passwd ${user} | cut -d: -f 6)/.bash_profile"
fi

exec sudo -u '${user}' /bin/sh -c "cd \$PWD; exec bash --login -i"
EOF

}

shit() {
  local user args container

  user=""
  container=""

  args=()
  while [[ $# -gt 0 ]]; do
    arg="$1"
    case $arg in
    -u=)
      user="${arg#*=}"
      shift
      ;;
    -u | --user)
      user="$2"
      shift
      shift
      ;;
    -u*)
      user="${arg:2}"
      shift
      ;;
    --rm|--tty|-t|-P|--publish-all|-d|--detach|--help|--init|--no-healthcheck|--oom-kill-disable|--privileged|--sig-proxy)
      args+=("$arg")
      shift
      ;;
    *)
      if [[ $arg =~ ^(-[a-zA-Z]|--[a-zA-Z\-]+)= ]]; then
        args+=("$arg")
        shift
      elif [[ $arg =~ ^(-[a-zA-Z]|--[a-zA-Z\-]+)$ ]]; then
        args+=("$arg" "$2")
        shift
        shift
      elif [[ -z $container ]]; then
        container="$arg"
        shift
      else
        >&2 printf "WARNING: found an unmatched argument '%s', will continue, but something probably went wrong with parsing docker/podman args\n" "$arg"
        args+=("$arg")
        shift
      fi
      ;;
    esac
  done

  if [[ $user == "" ]]; then
    user="$("$CONTAINER_RUNTIME" image inspect --format="{{ .ContainerConfig.User }}" "$container")"
    user="${user:-root}"
  fi

  \mkdir -p "$HOME/tmp/container-bash"
  localBashHistoryFile="$(mktemp -p "$HOME/tmp/container-bash" -t "XXXXXXXX.${container//[:\/]/}.bash_history")"
  \chmod 777 "$localBashHistoryFile"
  remoteBashHistoryFile="$(mktemp -t 'XXXXXXXX.bash_history' --dry-run)"

  >&2 printf "\e[33mINFO: Running container '%s' with args '%s'\e[m\n" "$container" "${args[*]}"
  >&2 printf "\e[33mINFO: The container's bash_history is at '%s'\e[m\n" "$localBashHistoryFile"
  "$CONTAINER_RUNTIME" run -it --rm --entrypoint /bin/sh -v "$localBashHistoryFile:$remoteBashHistoryFile" -v "${PWD}:/workdir" -u root -w /workdir "${args[@]}" "$container" -c "$(_shit_run_script "$user" "$remoteBashHistoryFile")"
  >&2 printf "\e[33mINFO: Remember, your container's bash_history is at '%s'\e[m\n" "$localBashHistoryFile"

  # todo add cron to clean up bash histories
}
