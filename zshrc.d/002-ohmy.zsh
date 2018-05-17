export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

HIST_STAMPS="dd/mm/yyyy"

plugins=(\
    git\
    gitfast\
    git-extras\
    aws\
    command-not-found\
    composer\
    common-aliases\
    golang \
    osx\
    pip\
    virtualenv\
    kubectl\
    docker\
    brew\
    autoupdate\
    fast-syntax-highlighting\
    zsh-autosuggestions\
    zsh-history-substring-search)

source "$ZSH/oh-my-zsh.sh"

zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
