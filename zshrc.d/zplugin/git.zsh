zinit ice wait"1" silent atload'alias gds="gd --staged"'
zinit light wfxr/forgit

zinit ice lucid wait"0" as"program" from"gh-r" \
    pick"delta*/delta"
zinit light 'dandavison/delta'
