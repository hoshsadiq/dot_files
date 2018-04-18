# Reload the shell completely
alias shreload="exec ${SHELL}"

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc
alias more='less'
alias nano='vim'
alias path='echo -e ${PATH//:/\\n}'

# Some shortcuts for different directory listings
alias lsd='ll | grep --color=never "^d"'
alias lla='ll -a'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"