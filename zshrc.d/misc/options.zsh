setopt AUTO_CD                   # Automatically cd in to directories if it's not a command name.
setopt MULTIOS
setopt PROMPT_SUBST              # Expand parameters within prompts.
setopt LOCAL_OPTIONS             # Options set/unset inside functions, stay within the function.
setopt INTERACTIVE_COMMENTS      # Allow me to comment lines in an interactive shell.

# Completion Options
setopt AUTO_LIST                 # Always automatically show a list of ambiguous completions.
setopt COMPLETE_IN_WORD          # Complete items from the beginning to the cursor.

setopt NO_BRACE_CCL              # don't expand of {adasd}

## ignores filenames already in the line
zstyle ':completion:*:(rm|kill|diff):*' ignore-line yes

# Kill colors aren't always correct in the default one provided by oh-my-zsh
zstyle ':completion:*:processes' command 'ps -au$USER -o pid,time,cmd|grep -v "ps -au$USER -o pid,time,cmd"'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)[ 0-9:]#([^ ]#)*=01;30=01;31=01;38'
# extra settings for the "kill"-command
zstyle ':completion:*:*:*:*:processes' menu yes select
zstyle ':completion:*:(killall|pkill|kill):*' menu yes select
zstyle ':completion:*:(killall|pkill|kill):*' force-list always

# Search the end and beginning when tab completing
zstyle ':completion:*' matcher-list 'l:|=* r:|=*'

# Populate hostname completion.
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//,/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'
zstyle -e ':completion:*:(ping|host):*' hosts 'reply=(
  ${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[# ]*}//,/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
)'

# complete hosts and users
zstyle ':completion:*:(ssh|scp|ftp):*' hosts $hosts
zstyle ':completion:*:(ssh|scp|ftp):*' users $users
# SSH/SCP/RSYNC
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order users 'hosts:-host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*.*' loopback localhost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^*.*' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^<->.<->.<->.<->' '127.0.0.<->'

# This fixes an issue when the selection doesn't go away when pressing enter
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
