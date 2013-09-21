# If not running interactively, don't do anything

[[ -z "$PS1" ]] && return
[[ $TERM != "screen" ]] && screen

# include other files
[[ -r ~/.bash_colors ]] && . ~/.bash_colors # colors
[[ -r ~/.bash_aliases ]] && . ~/.bash_aliases # aliases
[[ -r ~/.bash_functions ]] && . ~/.bash_functions # functions
[[ -r ~/.bash_prompt ]] && . ~/.bash_prompt # promps
[[ -r ~/.bash_completion ]] && . ~/.bash_completion # custom bash completition
[[ -r ~/.bash_local ]] && . ~/.bash_local # custom bash completition
[[ -r ~/.bashrc ]] && . ~/.bashrc # aliases
[[ -r ~/.profile ]] && . ~/.profile # aliases
