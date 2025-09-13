#!/usr/bin/env zsh

set -euo pipefail

plugin_home="$1"

tmux_home="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
mkdir -p "$tmux_home"
if [[ ! -h "$tmux_home/tmux.conf" ]]; then
  ln -s "$plugin_home/.tmux.conf" "$tmux_home/tmux.conf"
fi
if [[ ! -h "$tmux_home/tmux.conf.local" ]]; then
  if [[ ! -f "$DOT_FILES/config/tmux/.tmux.overrides.conf" ]]; then
    cp "$plugin_home/.tmux.conf.local" "$DOT_FILES/config/tmux/.tmux.overrides.conf"
  fi
  ln -fs "$DOT_FILES/config/tmux/.tmux.overrides.conf" "$tmux_home/tmux.conf.local"
fi
