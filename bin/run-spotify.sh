#!/usr/bin/env sh

spid="$(ps ax | awk '/ (\/snap\/spotify\/[0-9]+)?\/usr\/share\/spotify\/spotify$/{print $1}')"

if [ -n "$spid" ]; then
  wmctrl -ia "$(wmctrl -lp | awk -vpid="$spid" '$3==pid {print $1; exit}')"
else
  spotify "$@"
fi
