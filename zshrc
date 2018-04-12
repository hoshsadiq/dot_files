[ ! -z "$ZSH_START_TIMINGS" ] && zmodload zsh/zprof

# todo: determine dot_files dir
DOT_FILES="$HOME/dot_files"

if [ -d "$DOT_FILES/zshrc.d" ]; then
  for file in $HOME/dot_files/**/*.zsh; do
    source $file
  done
fi

[ ! -z "$ZSH_START_TIMINGS" ] && zprof

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
# GBT_RCARS='Time'
GBT_CAR_SIGN_WRAP='1'

# precmd() {
#   LEFT='$(gbt $?)'
#   RIGHT='$(gbt -right)'
#   RIGHTWIDTH=$(($COLUMNS-${#LEFT}))
#   print $LEFT${(l:$RIGHTWIDTH:: :)RIGHT}
# }

# source "$(brew --prefix kube-ps1)/share/kube-ps1.sh"

# export GBT_CAR_CUSTOM_CMD="echo 'test'"
# export GBT_CAR_CUSTOM_DISPLAY_CMD="echo YES"
# # export GBT_CAR_CUSTOM_BG="default"
# # export GBT_CAR_CUSTOM_FG="default"
# export GBT_CARS='Status, Os, Hostname, Dir, Git, Custom, Sign'
# export GBT_DEBUG='0'

PROMPT='$(gbt $?)'
# RPROMPT='$(gbt -right)'

unalias grv

export SDKMAN_DIR="/Users/hoshang.sadiq/.sdkman"
[[ -s "/Users/hoshang.sadiq/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/hoshang.sadiq/.sdkman/bin/sdkman-init.sh"

[ ! -z "$ZSH_START_TIMINGS" ] && zprof
