[ -f ~/.zshrc_local ] && source ~/.zshrc_local

# todo: determine dot_files dir
DOT_FILES="$HOME/dot_files"

ZSH_THEME="powerlevel9k/powerlevel9k"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

plugins=(\
    git\
    gitfast\
    git-extras\
    aws\
    command-not-found\
    composer\
    common-aliases\
    mvn\
    osx\
    pip\
    virtualenv\
    kubectl\
    hosh\
    docker\
    brew\
    zsh-syntax-highlighting\
    zsh-history-substring-search)

source "$DOT_FILES/.powerlevel9k_config"
source "$DOT_FILES/.zsh_exports"
source "$ZSH/oh-my-zsh.sh"
# source $HOME/bashrc_enhancements/files/ssh

[ -f "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

[ -f /usr/libexec/path_helper ] && eval $(/usr/libexec/path_helper -s)
