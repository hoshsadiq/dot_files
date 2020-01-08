_zsh-notify-setting() {
  zstyle ':notify:*' error-title "Command failed (in #{time_elapsed} seconds)"
  zstyle ':notify:*' success-title "Command finished (in #{time_elapsed} seconds)"
}

zplugin ice wait"2" atload"_zsh-notify-setting" lucid
zplugin light marzocchi/zsh-notify
