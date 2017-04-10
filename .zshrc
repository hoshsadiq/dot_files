# If you come from bash you might have to change your $PATH.
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home
export PATH=$HOME/bin:$PATH
export PATH=$JAVA_HOME/bin:$PATH
export SDKMAN_DIR="$HOME/.sdkman"

# Path to your oh-my-zsh installation.
export ZSH=/Users/hosh/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel9k/powerlevel9k"

[[ -s "/Users/hosh/.powerlevel9k_config" ]] && source "/Users/hosh/.powerlevel9k_config"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
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

source $ZSH/oh-my-zsh.sh
# source $HOME/bashrc_enhancements/files/ssh

export LC_ALL=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LOCALE=en_GB.UTF-8
export EDITOR='vim'
export HISTCONTROL=ignoredups

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
[ -f "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

alias gits="git status"
alias gds="git diff --staged"

eval $(/usr/libexec/path_helper -s)
