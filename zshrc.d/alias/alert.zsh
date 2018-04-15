# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
# todo: allow for MacOS
#if stringContains "darwin" "$OSTYPE"; then
#  alert() {
#    /usr/bin/osascript -e 'display notification system attribute "X"'
#  }
#else
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
#fi
