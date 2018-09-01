# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi


bindkey '^[OH' beginning-of-line # [Home] - Go to beginning of line
bindkey '^A' beginning-of-line # Ctrl+A - Go to beginning of line
bindkey '^[OF' end-of-line # [End] - Go to end of line
bindkey '^E' end-of-line # Ctrl+E - Go to end of line

bindkey '^?' backward-delete-char # [Backspace] - delete backward
bindkey "^[[3~" delete-char # [Delete] - delete forward

bindkey ' ' magic-space # [Space] - do history expansion

bindkey '^[[1;5C' forward-word # [Ctrl-RightArrow] - move forward one word
bindkey '^[f' forward-word # [Alt+F] - move forward one word
bindkey '^[[1;5D' backward-word # [Ctrl-LeftArrow] - move backward one word
bindkey '^[b' backward-word # [Alt+B] - move backward one word

bindkey '^K' kill-line
bindkey '^U' kill-whole-line

bindkey "${terminfo[kcbt]}" reverse-menu-complete # [Shift-Tab] - move through the completion menu backwards

# Edit the current command line in $EDITOR
# autoload -U edit-command-line
# zle -N edit-command-line
# bindkey '\C-x\C-e' edit-command-line

bindkey "^[m" copy-prev-shell-word

# history-substring-search
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
