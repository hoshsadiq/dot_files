# editor
export EDITOR='vim'
export GIT_EDITOR="$EDITOR"

# X Server display
export DISPLAY=:0.0

# Highlight less
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R'

# GPG Signing git commits
export GPG_TTY=$(tty)
