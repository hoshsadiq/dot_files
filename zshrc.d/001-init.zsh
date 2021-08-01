autoload -U zcalc
autoload -U zmv

zmodload zsh/terminfo
zmodload zsh/complist

autoload -Uz add-zsh-hook

autoload -U +X bashcompinit
bashcompinit

autoload -Uz compinit
compinit

# Bash-like help support. To find help files, we may also need to set HELPDIR environment variable with
# something like /path/to/zsh_help_directory.
unalias run-help 2>/dev/null
autoload run-help
alias help=run-help
