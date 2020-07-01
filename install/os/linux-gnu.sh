#!/usr/bin/env zsh

set -e

# todo this is untested.

source /etc/os-release
if grep -Eiq '(mint|ubuntu)' <<<"$NAME ${ID_LIKE:-}"; then
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    source ./linux-gnu/ubuntu-preapps.sh
    source ./linux-gnu/ubuntu-apps.sh
#    source ./linux-gnu/ubuntu-settings.sh

    # Section "InputClass"
    #         Identifier "libinput touchpad catchall"
    #         MatchIsTouchpad "on"
    #         MatchDevicePath "/dev/input/event*"
    #         Driver "libinput"
    #         Option "Tapping" "off"
    #         Option "TappingButtonMap" "lrm"
    #         Option "CoastingSpeed" "35"
    #         Option "CoastingFriction" "40"
    #         Option "FingerLow" "30"
    #         Option "FingerHigh" "50"
    # EndSection
else
  echo "Platform not supported"
  exit 1;
fi
