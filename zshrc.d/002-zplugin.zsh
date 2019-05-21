source "$HOME/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin

zmodload -i zsh/complist
autoload -Uz compinit
compinit

# oh my zsh plugins
zplugin snippet OMZ::lib/clipboard.zsh
zplugin snippet OMZ::lib/completion.zsh
zplugin snippet OMZ::lib/grep.zsh
zplugin snippet OMZ::lib/spectrum.zsh
zplugin snippet OMZ::lib/termsupport.zsh
zplugin snippet OMZ::lib/history.zsh

# todo why does aws/golang not work when it comes to completion?
# zplugin snippet OMZ::plugins/aws/aws.plugin.zsh
zplugin snippet OMZ::plugins/golang/golang.plugin.zsh
zplugin snippet OMZ::plugins/common-aliases/common-aliases.plugin.zsh
zplugin snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zplugin snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh
zplugin snippet OMZ::plugins/globalias/globalias.plugin.zsh

# zplugin snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zplugin light zdharma/history-search-multi-word
zplugin light zsh-users/zsh-autosuggestions
zplugin light zdharma/fast-syntax-highlighting
#zplugin light denysdovhan/spaceship-prompt/ #spaceship prompt is extra slow tho
zplugin light zsh-users/zsh-history-substring-search

# todo these need to be loaded conditionally
# zplugin snippet OMZ::plugins/osx/osx.plugin.zsh

# todo consider these, do i need it? they seem cool...
# zplugin light tj/git-extras
# zplugin load zdharma/zui
# zplugin ice from"gh-r" as"program"; zplugin load junegunn/fzf-bin
