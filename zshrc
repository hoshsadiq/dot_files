[ ! -z "$ZSH_START_TIMINGS" ] && zmodload zsh/zprof

[ -f ~/.zshrc_local ] && source ~/.zshrc_local

# todo: determine dot_files dir
DOT_FILES="$HOME/dot_files"

ZSH_THEME="robbyrussell"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

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
    fast-syntax-highlighting\
    zsh-history-substring-search)

source "$DOT_FILES/zsh_exports"
source "$ZSH/oh-my-zsh.sh"

if [ -d "$HOME/apps/google-cloud-sdk" ]; then
  source "$HOME/apps/google-cloud-sdk/completion.zsh.inc"
  source "$HOME/apps/google-cloud-sdk/path.zsh.inc"
fi
# source $HOME/bashrc_enhancements/files/ssh

zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

[ -f /usr/libexec/path_helper ] && eval $(/usr/libexec/path_helper -s)

source "$DOT_FILES/login_message"

GBT_CAR_DIR_DEPTH='2'
GBT_RCARS='Time'
GBT_CAR_SIGN_WRAP='1'

# precmd() {
#   LEFT='$(gbt $?)'
#   RIGHT='$(gbt -right)'
#   RIGHTWIDTH=$(($COLUMNS-${#LEFT}))
#   print $LEFT${(l:$RIGHTWIDTH:: :)RIGHT}
# }
PROMPT='$(gbt $?)'
# RPROMPT='$(gbt -right)'

[ ! -z "$ZSH_START_TIMINGS" ] && zprof
