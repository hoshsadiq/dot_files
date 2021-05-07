autoload -U zcalc
autoload -U zmv

zmodload zsh/terminfo
zmodload zsh/complist

autoload -Uz add-zsh-hook

autoload -U +X bashcompinit
bashcompinit

autoload -Uz compinit
compinit
