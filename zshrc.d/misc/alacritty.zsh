export MANPATH="$MANPATH:$HOME/.local/share/man"

zinit ice id-as"alacrity---zsh-completions" as"completion" \
  wait silent blockf has'alacritty'
zinit snippet https://github.com/alacritty/alacritty/blob/$(alacritty --version )/extra/completions/_alacritty
