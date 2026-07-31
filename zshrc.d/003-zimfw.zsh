# Guard against non-interactive shells. Use [[ -o interactive ]] instead of
# [[ -t 0 ]] because atuin's preexec background process can temporarily hold
# the tty fd during `exec $SHELL -l`, causing -t 0 to spuriously fail.
if [[ ! -o interactive ]]; then
  return
fi

ZIM_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}/zim
ZIM_CONFIG_FILE="$DOT_FILES/config/zsh/zimrc"

# Relocate zsh's compdump out of $HOME. Must be set BEFORE zim's completion
# module runs, since zim's completion init reads this zstyle to decide where
# to place `.zcompdump{,.dat,.zwc}`.
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
zstyle ':zim:completion' dumpfile \
    "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

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

# Dedupe fpath BEFORE zim's completion module builds its dumpfile hash.
# Zim's completion module (modules/completion/init.zsh) hashes every entry in
# ${fpath} + each entry's file mtimes to decide whether the `.zcompdump.dat`
# cache is stale. Duplicate fpath entries (this setup has 111 entries with
# some appearing up to 12x) cause the hash to grow on every startup, which
# forces a full compdump rebuild each time (~380ms on this machine). Making
# fpath uniquely-typed *before* init.zsh runs collapses duplicates so the
# cache actually hits.
typeset -U fpath

# Initialize modules.
source "${ZIM_HOME}/init.zsh"
