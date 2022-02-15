zinit light willghatch/zsh-saneopt

setopt auto_cd                   # Automatically cd in to directories if it's not a command name.
setopt multios
setopt local_options             # Options set/unset inside functions, stay within the function.
setopt interactive_comments      # Allow me to comment lines in an interactive shell.
setopt no_flow_control           # Free up Ctrl-Q and Ctrl-S

# Completion Options
setopt auto_list                 # Always automatically show a list of ambiguous completions.
setopt complete_in_word          # Complete items from the beginning to the cursor.

setopt no_brace_ccl              # don't expand of {adasd}

# This fixes an issue when the selection doesn't go away when pressing enter
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
zstyle ':bracketed-paste-magic' active-widgets '.self-*'
