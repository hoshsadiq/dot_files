#export MANPATH="$MANPATH:$HOME/.local/share/man"

zinit ice id-as"alacritty---zsh-completions" as"completion" \
  wait silent blockf has'alacritty'
zinit snippet "https://github.com/alacritty/alacritty/releases/download/v$(alacritty --version | awk '{print $2}')/_alacritty"
