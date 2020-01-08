alias history='fc -t "%d/%m/%Y %H:%M:%S" -l 1'

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"

HISTSIZE=100000
HISTFILESIZE=$HISTSIZE
SAVEHIST=$HISTSIZE

## History command configuration
setopt bang_hist                 # Treat the '!' character specially during expansion.
setopt extended_history          # Write the history file in the ":start:elapsed;command" format.
setopt inc_append_history        # Write to the history file immediately, not when the shell exits.
setopt share_history             # Share history between all sessions.
setopt hist_expire_dups_first    # Expire duplicate entries first when trimming history.
setopt hist_ignore_dups          # Don't record an entry that was just recorded again.
setopt hist_ignore_all_dups      # Delete old recorded entry if new entry is a duplicate.
setopt hist_find_no_dups         # Do not display a line previously found.
setopt hist_ignore_space         # Don't record an entry starting with a space.
setopt hist_save_no_dups         # Don't write duplicate entries in the history file.
setopt hist_reduce_blanks        # Remove superfluous blanks before recording entry.
setopt hist_verify               # Don't execute immediately upon history expansion.
setopt hist_beep                 # Beep when accessing nonexistent history.

HISTIGNORE='&:[ ]*:exit:ls:bg:fg:history:clear:gd:gds'


bindkey -r '^[[A'
bindkey -r '^[[B'
function __bind_history_keys() {
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
}

zplugin ice depth=1 wait silent
zplugin light zdharma/history-search-multi-word

zplugin ice depth=1 wait silent
zplugin snippet OMZ::lib/history.zsh

zplugin ice depth=1 wait silent atload'__bind_history_keys'
zplugin light zsh-users/zsh-history-substring-search
