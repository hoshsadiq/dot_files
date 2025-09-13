#!/usr/bin/env sh

set -eux

[ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ] && >&2 printf "Must be run inside docker" && return 1

[ -z "${SHIT_DOCKER_USER:-}" ] && printf >&2 "SHIT_DOCKER_USER is blank\n";
#[ -z "${SHIT_BASH_HISTORY_FILE:-}" ] && printf >&2 "SHIT_BASH_HISTORY_FILE is blank\n";
[ -z "${SHIT_USER_UID:-}" ] && printf >&2 "SHIT_USER_UID is blank\n";
[ -z "${SHIT_USER_GID:-}" ] && printf >&2 "SHIT_USER_GID is blank\n";
[ -z "${SHIT_REAL_USERNAME:-}" ] && printf >&2 "SHIT_REAL_USERNAME is blank\n";

if command -v apt-get >/dev/null; then
  printf >&2 "\e[33mSetting DEBIAN_FRONTEND=noninteractive; Remember to set it in your Dockerfile if you need.\e[m\n"
  export DEBIAN_FRONTEND=noninteractive
fi

if [ ! -f /etc/os-release ]; then
  command -v bash >/dev/null && exec bash --login -i
  command -v sh >/dev/null && exec sh -l
  printf >&2 "I don't know what to do! I can't find os-release. I can't find bash. I can't find sh. I'm lost. Save me!"
  exit 1
fi

. /etc/os-release

packages="sudo neovim"
command -v bash >/dev/null || packages="$packages bash"

command -v microdnf >/dev/null && packages="$(printf %s "$packages" | sed 's/neovim/vim/')"
>&2 echo "installing packages '$packages' first..."
{
  command -v apt-get >/dev/null && echo 'APT::Get::Assume-Yes "true";' >> /etc/apt/apt.conf.d/quiet && apt-get update -qq && apt-get -qq install -o=Dpkg::Use-Pty=0 -y $packages
  command -v apk >/dev/null && apk add --no-cache -q --no-progress $packages
  command -v yum >/dev/null && yum install -q -y $packages
 command -v microdnf >/dev/null && microdnf install -y $packages >/dev/null 2>&1
} 2>&1 | tee /tmp/container-setup.log

env | grep -E -v '^(HOME=|USER=|MAIL=|LC_ALL=|LS_COLORS=|LANG=|HOSTNAME=|PWD=|TERM=|SHLVL=|LANGUAGE=|_=)' >> /etc/environment
if command -v nvim >/dev/null; then
  ln -fs "$(command -v nvim)" /usr/bin/vim
  ln -fs "$(command -v nvim)" /usr/bin/vi
fi

{
  groupadder=addgroup
  if command -v groupadd >/dev/null; then
    groupadder=groupadd
  fi
  "$groupadder" --gid "$SHIT_USER_GID" "$SHIT_REAL_USERNAME"
  grp_in_ctr="$(awk -F: "\$3 == $SHIT_USER_GID{print \$1}" /etc/group)"
  adduser --uid "$SHIT_USER_UID" --ingroup "$grp_in_ctr" --home "/home/$SHIT_REAL_USERNAME" --gecos "" --disabled-password "$SHIT_REAL_USERNAME"
  echo "$SHIT_REAL_USERNAME ALL=(ALL:ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$SHIT_REAL_USERNAME"
} 2>&1 | tee /tmp/container-setup.log

cat /etc/shit/profile.sh >> "$(getent passwd root | cut -d: -f 6)/.bash_profile"
cat /etc/shit/profile.sh >> "$(getent passwd "$SHIT_REAL_USERNAME" | cut -d: -f 6)/.bash_profile"
if [ -n "${SHIT_DOCKER_USER:-}" ] && [ "$SHIT_DOCKER_USER" != "$SHIT_REAL_USERNAME" ] && [ "$SHIT_DOCKER_USER" != "root" ]; then
  cat /etc/shit/profile.sh >> "$(getent passwd "$SHIT_DOCKER_USER" | cut -d: -f 6)/.bash_profile"
fi

cat <<EOF > /etc/pip.conf
[install]
break-system-packages = true
EOF

exec sudo -u "$SHIT_DOCKER_USER" /bin/sh -c "cd $PWD; exec bash --login -i"
