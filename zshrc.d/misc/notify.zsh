if [[ -z "$DISPLAY" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]] || (( ! $+commands[xdotool] )) || (( ! $+commands[wmctrl] )); then
  return
fi

_zsh-notify-setting() {
  zstyle ':notify:*' error-title "Command failed (in #{time_elapsed} seconds)"
  zstyle ':notify:*' success-title "Command finished (in #{time_elapsed} seconds)"

  zstyle ':notify:*' expire-time 300
  zstyle ':notify:*' disable-urgent true
  zstyle ':notify:*' command-complete-timeout 15
  zstyle ':notify:*' blacklist-regex '^less|\|\s*less'
}

zinit ice wait"2" atload"_zsh-notify-setting" lucid
zinit light marzocchi/zsh-notify
