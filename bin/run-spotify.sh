#!/usr/bin/env sh

xprop="$(xprop -name spotify _NET_WM_PID 2>/dev/null)"
retcode="$?"
if [ "$retcode" = "0" ]; then
  spid="$(printf "%s" "$xprop" | awk -F' = ' '{print $2}')"
  wid="$(wmctrl -lp | awk -vpid="$spid" '$3==pid {print $1; exit}')"
  if [ -z "$wid" ]; then
    killall spotify
  else
    wmctrl -ia "$wid"
    exit 0
  fi
fi

exec spotify "$@" --force-device-scale-factor=2
