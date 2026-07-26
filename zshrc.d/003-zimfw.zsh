# Guard against non-interactive shells. Use [[ -o interactive ]] instead of
# [[ -t 0 ]] because atuin's preexec background process can temporarily hold
# the tty fd during `exec $SHELL -l`, causing -t 0 to spuriously fail.
if [[ ! -o interactive ]]; then
  return
fi

ZIM_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}/zim
ZIM_CONFIG_FILE="$DOT_FILES/config/zsh/zimrc"

# Download zimfw plugin manager if missing.
if [[ ! -e "${ZIM_HOME}/zimfw.zsh" ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o "${ZIM_HOME}/zimfw.zsh" \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p "${ZIM_HOME}" && wget -nv -O "${ZIM_HOME}/zimfw.zsh" \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! "${ZIM_HOME}/init.zsh" -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source "${ZIM_HOME}/zimfw.zsh" init
fi
# Initialize modules.
source "${ZIM_HOME}/init.zsh"
