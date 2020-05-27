zplugin ice wait"1" silent atload'alias gds="gd --staged"'
zplugin light wfxr/forgit

zplugin ice lucid wait"0" as"program" from"gh-r" \
    pick"delta*/delta"
zplugin light 'dandavison/delta'
