# Expand aliases for sudo and other commands
alias sudo='sudo '
alias watch='watch '
alias -g '¬= '

# Reload the shell completely
alias shreload="exec $SHELL -l"

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc
alias more='less'
alias nano='vim'

# Some shortcuts for different directory listings
alias lsd='ll | grep --color=never "^d"'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# edits dot files
alias edots="atom $DOT_FILES $ZSH"

alias diff="git diff --no-index --exit-code --color-words"

alias ansistrip='sed "s/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g"'
