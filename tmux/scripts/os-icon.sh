#!/usr/bin/env bash

set -euo pipefail

# set -x
# echo "start at: $(date)" >&2
# exec 2> /tmp/tmux-os-icon.log

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/../helpers/helpers.sh"

declare -A os_icons
os_icons=(
  [alpine]='\uf300'
  [amzn]='\uf270'
  [android]='\ue70e'
  [aosc]='\uf301'
  [darwin]='\uf302'
  [arch]='\uf303'
  [centos]='\uf304'
  [coreos]='\uf305'
  [debian]='\uf306'
  [devuan]='\uf307'
  [docker]='\uf308'
  [elementary]='\uf309'
  [fedora]='\uf30a'
  [freebsd]='\uf30c'
  [gentoo]='\uf30d'
  [linux]='\uf31a'
  [linuxmint]='\uf30f'
  [mageia]='\uf310'
  [mandriva]='\uf311'
  [manjaro]='\uf312'
  [nixos]='\uf313'
  [opensuse]='\uf314'
  [raspbian]='\uf315'
  [rhel]='\uf316'
  [sabayon]='\uf317'
  [slackware]='\uf318'
  [ubuntu]='\uf31b'
  [windows]='\ue70f'
)

# todo need to add an option for colors
# declare -A options
# options[enable-color]='\uf817'
#
# function update_options {
#   for option in "${!options[@]}"; do
#     options[$option]="$(get_tmux_option "@os-icon-$option" -w -d "${options[$option]}")"
#   done
# }

function print_os_icon {
  if [[ $(uname -o &>/dev/null) == Android ]]; then
    printf "${os_icons[android]}"
  elif grep -Fq docker /proc/1/cgroup; then
    printf "${os_icons[docker]}"
  else
    case $(uname) in
      Darwin)                       printf "${os_icons[darwin]}"      ;;
      CYGWIN_NT-* | MSYS_NT-*)      printf "${os_icons[windows]}"     ;;
      FreeBSD|OpenBSD|DragonFly)    printf "${os_icons[freebsd]}"     ;;
      Linux)
        [[ -f /etc/os-release ]] && source /etc/os-release
        case "$ID" in
          *alpine*)                 printf "${os_icons[alpine]}"      ;;
          *amzn*)                   printf "${os_icons[amzn]}"        ;;
          *aosc*)                   printf "${os_icons[aosc]}"        ;;
          *arch*)                   printf "${os_icons[arch]}"        ;;
          *centos*)                 printf "${os_icons[centos]}"      ;;
          *coreos*)                 printf "${os_icons[coreos]}"      ;;
          *debian*)                 printf "${os_icons[debian]}"      ;;
          *devuan*)                 printf "${os_icons[devuan]}"      ;;
          *elementary*)             printf "${os_icons[elementary]}"  ;;
          *fedora*)                 printf "${os_icons[fedora]}"      ;;
          *gentoo*)                 printf "${os_icons[gentoo]}"      ;;
          *linuxmint*)              printf "${os_icons[linuxmint]}"   ;;
          *mageia*)                 printf "${os_icons[mageia]}"      ;;
          *mandriva*)               printf "${os_icons[mandriva]}"    ;;
          *manjaro*)                printf "${os_icons[manjaro]}"     ;;
          *nixos*)                  printf "${os_icons[nixos]}"       ;;
          *opensuse*|*tumbleweed*)  printf "${os_icons[opensuse]}"    ;;
          *raspbian*)               printf "${os_icons[raspbian]}"    ;;
          *rhel*)                   printf "${os_icons[rhel]}"        ;;
          *sabayon*)                printf "${os_icons[sabayon]}"     ;;
          *slackware*)              printf "${os_icons[slackware]}"   ;;
          *ubuntu*)                 printf "${os_icons[ubuntu]}"      ;;
          *)                        printf "${os_icons[linux]}"       ;;
        esac
        ;;
    esac
  fi
}

# this logic is based on powerlevel9k
main() {
  # update_options

  print_os_icon
}

main
