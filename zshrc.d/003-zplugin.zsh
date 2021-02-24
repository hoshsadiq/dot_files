if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# oh my zsh plugins
zinit ice depth=1 wait silent
zinit snippet OMZ::lib/clipboard.zsh
zinit ice depth=1 wait silent
zinit snippet OMZ::lib/grep.zsh
zinit ice depth=1 wait silent
zinit snippet OMZ::lib/spectrum.zsh
zinit ice depth=1 wait silent
zinit snippet OMZ::lib/termsupport.zsh

#zinit ice depth=1 wait'1' silent
#zinit snippet OMZ::plugins/common-aliases/common-aliases.plugin.zsh
zinit ice depth=1 wait silent
zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zinit ice depth=1 wait silent
zinit snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh
#zinit ice depth=1 wait silent
zinit snippet OMZ::plugins/globalias/globalias.plugin.zsh

zinit ice depth=1 wait"1" compile'{src/*.zsh,src/strategies/*}' silent atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice wait"1" silent
zinit light hlissner/zsh-autopair

zinit ice wait"2" as"program" pick"tldr" silent
zinit light raylee/tldr

zinit ice silent
zinit light Aloxaf/fzf-tab

zinit ice depth'1' wait"0a" atload"_zsh_highlight" silent
zinit light zdharma/fast-syntax-highlighting

# this is quite buggy as of yet, so maybe in the future
#zinit ice silent
#zinit light marlonrichert/zsh-autocomplete

# todo these need to be loaded conditionally
# zinit snippet OMZ::plugins/osx/osx.plugin.zsh

# todo consider these, do i need it? they seem cool...
# zinit light tj/git-extras
# zinit load zdharma/zui
