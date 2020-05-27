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

export KEYTIMEOUT=1

bindkey -v

bindkey '^[[1~' beginning-of-line # [Home] - Go to beginning of line
bindkey '^A' beginning-of-line # Ctrl+A - Go to beginning of line
bindkey '^[[4~' end-of-line # [End] - Go to end of line
bindkey '^E' end-of-line # Ctrl+E - Go to end of line

bindkey '^?' backward-delete-char # [Backspace] - delete backward
bindkey "^[[3~" delete-char # [Delete] - delete char
bindkey "^H" backward-delete-word # [Ctrl+Backspace] - delete word backwards
bindkey "^[[3;5~" delete-word # Ctrl+Del - delete word
bindkey "^[d" delete-word # Ctrl+Del - delete word

bindkey ' ' magic-space # [Space] - do history expansion

# todo should probably have Ctrl+Left/Right arrow on Linux only, and on Mac should be Alt+Left/Right
bindkey '^[[1;5C' forward-word # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word # [Ctrl-LeftArrow] - move backward one word
bindkey '^[f' forward-word # [Alt+F] - move forward one word
bindkey '^[b' backward-word # [Alt+B] - move backward one word

bindkey '^K' kill-line # Ctrl+K kill cursor to end of line
bindkey '^U' kill-whole-line # Ctrl+U kill whole line
bindkey "^[w" kill-region # Alt+w kill cursor to beginning of line
bindkey '^w' backward-kill-word # ctrl-w removed word backwards
bindkey "^Y" yank # Ctrl+Y paste what was previously killed

# These two lines are the same, but for some reason it doesn't work within tmux
bindkey "^[[Z" reverse-menu-complete # [Shift-Tab] - move through the completion menu backwards

# Edit the current command line in $EDITOR
# autoload -U edit-command-line
# zle -N edit-command-line
# bindkey '\C-x\C-e' edit-command-line

bindkey "^[m" copy-prev-shell-word

bindkey '^R' history-search-multi-word

bindkey "^@" set-mark-command

bindkey "^[[6~" down-line-or-history
bindkey "^[[5~" up-line-or-history

bindkey '^[?' run-help
