source "$HOME/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

zmodload -i zsh/complist
autoload -Uz compinit
compinit

# oh my zsh plugins
zplugin ice depth=1 wait silent
zplugin snippet OMZ::lib/clipboard.zsh
zplugin ice depth=1 wait silent
zplugin snippet OMZ::lib/grep.zsh
zplugin ice depth=1 wait silent
zplugin snippet OMZ::lib/spectrum.zsh
zplugin ice depth=1 wait silent
zplugin snippet OMZ::lib/termsupport.zsh

#zplugin ice depth=1 wait'1' silent
#zplugin snippet OMZ::plugins/common-aliases/common-aliases.plugin.zsh
zplugin ice depth=1 wait silent
zplugin snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zplugin ice depth=1 wait silent
zplugin snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh
#zplugin ice depth=1 wait silent
zplugin snippet OMZ::plugins/globalias/globalias.plugin.zsh

zplugin ice depth=1 wait"0a" compile'{src/*.zsh,src/strategies/*}' silent atload'_zsh_autosuggest_start'
zplugin light zsh-users/zsh-autosuggestions

zplugin ice wait"0b" silent
zplugin light hlissner/zsh-autopair

zplugin ice wait"2" as"program" pick"tldr" silent
zplugin light raylee/tldr

zplugin ice depth'1' wait"0a" atload"_zsh_highlight" silent
zplugin light zdharma/fast-syntax-highlighting

# todo these need to be loaded conditionally
# zplugin snippet OMZ::plugins/osx/osx.plugin.zsh

# todo consider these, do i need it? they seem cool...
# zplugin light tj/git-extras
# zplugin load zdharma/zui
