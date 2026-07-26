autoload -U zcalc
autoload -U zmv

zmodload zsh/terminfo
zmodload zsh/complist

autoload -Uz add-zsh-hook

autoload -U +X bashcompinit
bashcompinit

alias help=run-help

# zsh-vi-mode: reduce prompt interference with powerlevel10k.
# Without these, zvm's deferred init races with p10k's prompt setup,
# causing the prompt to randomly revert to the default on shell reload.
# See: romkatv/powerlevel10k#1618, jeffreytse/zsh-vi-mode#136
ZVM_LINE_INIT_MODE=i  # $ZVM_MODE_INSERT='i', but not yet defined here
ZVM_CURSOR_STYLE_ENABLED=false
ZVM_RESET_PROMPT_DISABLED=true
