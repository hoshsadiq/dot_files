# editor
export EDITOR='vim'
export GIT_EDITOR="$EDITOR"

# X Server display
export DISPLAY=:0.0

# page
export PAGER='less'

# Highlight less
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R'

# GPG Signing git commits
export GPG_TTY=$(tty)

# don't use the built-in virtualenv prompt
export VIRTUAL_ENV_DISABLE_PROMPT=true
