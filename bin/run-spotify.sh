#!/usr/bin/env bash

spotifyArgs=()
#spotifyArgs+=("--force-device-scale-factor=2") # todo automatically determine this based on desktop settings

xprop="$(xprop -name spotify _NET_WM_PID 2>/dev/null)"
retcode="$?"
if [ "$retcode" = "0" ]; then
  spid="$(awk -F' = ' '{print $2}' <<<"$xprop")"
  wid="$(wmctrl -lp | awk -vpid="$spid" '$3==pid {print $1; exit}')"
  if [ -z "$wid" ]; then # spotify is probably broken at this point
    killall spotify
  else
    wmctrl -ia "$wid"
    exit $?
  fi
fi

set -- "${spotifyArgs[@]}" "$@"

exec flatpak run --branch=stable --arch="$(uname -m)" --command=spotify --file-forwarding com.spotify.Client "$@"
