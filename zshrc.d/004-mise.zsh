# Manage zsh completions and man pages for mise-installed tools.
# Runs once at first prompt (after compinit), then on directory
# change for project-scoped tool versions.

# todo maybe this can be made more generic, something like:
#   $ mise config get | yq -p=toml -r '.tools | to_entries[]  | select(.value.completion?) | .key as $tool | .value.completion.format as $fmt | .value.completion.shells[] | [$tool, ., $fmt] | @tsv'
#   #kubectl	zsh	{bin} completion {shell}
#   #kubectl	bash	{bin} completion {shell}
#   #kubectl	fish	{bin} completion {shell}
#
#  where the config looks like:
#   $ grep -F 'completion]' -A3 mise.toml
#   [tools."kubectl".completion]
#   format = "{bin} completion {shell}"
#   shells = ["zsh", "bash", "fish"]

# manpath/MANPATH aren't auto-tied in all zsh versions
#(( ${+parameters[manpath]} )) || typeset -gT MANPATH manpath :

__load_mise_extras() {
  local install_path mise_data_dir
  local -a active_comp_dirs new_fpath
  local dir compfile line cmd kind funcname
  local cache_file compdef_cache cache_dir installs_dir

  command -v mise &>/dev/null || return 0
  [[ -o interactive ]] || return 0
  (( ${+functions[compdef]} )) || return 0

  mise_data_dir="${MISE_DATA_DIR:-${HOME}/.local/share/mise}"
  installs_dir="${mise_data_dir}/installs"
  cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"
  cache_file="${cache_dir}/mise-active-installs.txt"
  compdef_cache="${cache_dir}/mise-compdefs.tsv"

  # Cache the list of active tool install paths that actually contain a
  # `functions/` completion dir. `mise list --json` alone takes ~1.5s here
  # (100+ installs), and only ~25% of installs ship completions. Filter at
  # cache-generation time so warm runs iterate only useful entries.
  # Also pre-parse each compfile's #compdef header + detect bash-style
  # completions (`complete -C`) once, so warm runs skip all file reads.
  # Invalidate both caches when the installs directory mtime changes.
  if [[ ! -s $cache_file || $installs_dir -nt $cache_file ]]; then
    mkdir -p "$cache_dir"
    mise list --json 2>/dev/null \
      | jq -r '.[] | .[] | select(.active == true) | .install_path' \
      | while IFS= read -r install_path; do
          [[ -d "$install_path/functions" || -f "$install_path/init.zsh" ]] && print -r -- "$install_path"
        done \
      >| "$cache_file"

    : >| "$compdef_cache"
    while IFS= read -r install_path; do
      for compfile in "$install_path"/functions/_*(N); do
        [[ -f "$compfile" && -r "$compfile" ]] || continue
        read -r line < "$compfile" 2>/dev/null || continue
        [[ "$line" == "#compdef "* ]] || continue
        cmd="${line#\#compdef }"
        [[ "$cmd" == -* ]] && continue
        if grep -q 'complete -C' "$compfile" 2>/dev/null; then
          kind=bash
        else
          kind=autoload
        fi
        printf '%s\t%s\t%s\n' "$compfile" "$kind" "$cmd" >> "$compdef_cache"
      done
    done < "$cache_file"
  fi

  # Every cached path has functions/ or init.zsh (see above). Skip missing
  # functions/ for init-only tools like zoxide.
  while IFS= read -r install_path; do
    [[ -d "$install_path/functions" ]] && active_comp_dirs+=("$install_path/functions")
  done < "$cache_file"

  # --- Completions: update fpath ---

  # Deregister completions from stale mise dirs no longer active. Only fires
  # on chpwd when the active set actually changed (initial startup has no
  # stale entries since fpath doesn't yet contain any mise install paths).
  for dir in "${fpath[@]}"; do
    [[ "$dir" == "${mise_data_dir}/installs"* ]] || continue
    (( ${active_comp_dirs[(Ie)$dir]} )) && continue
    for compfile in "$dir"/_*(N); do
      [[ -f "$compfile" && -r "$compfile" ]] || continue
      read -r line < "$compfile" 2>/dev/null || continue
      [[ "$line" == "#compdef "* ]] || continue
      cmd="${line#\#compdef }"
      cmd="${cmd%% *}"
      compdef -d "$cmd" 2>/dev/null
    done
  done

  # Rebuild fpath: drop stale mise dirs, add active ones
  for dir in "${fpath[@]}"; do
    [[ "$dir" != "${mise_data_dir}/installs"* ]] && new_fpath+=("$dir")
  done
  for dir in "${active_comp_dirs[@]}"; do
    (( ${new_fpath[(Ie)$dir]} )) || new_fpath+=("$dir")
  done
  fpath=("${new_fpath[@]}")

  # Register completions from the pre-parsed cache (no file reads).
  local bashcompinit_loaded=0
  while IFS=$'\t' read -r compfile kind cmd; do
    [[ -n "$compfile" ]] || continue
    if [[ "$kind" == bash ]]; then
      if (( ! bashcompinit_loaded )); then
        autoload -Uz bashcompinit && bashcompinit 2>/dev/null
        bashcompinit_loaded=1
      fi
      source "$compfile"
    else
      funcname="${compfile:t}"
      autoload -Uz "$funcname"
      # word-splitting intentional: multi-command headers like "#compdef kubectx kctx=kubectx"
      compdef "$funcname" ${=cmd}
    fi
  done < "$compdef_cache"

  # --- Init scripts: source tool-provided shell code ---
  # Tools may ship $MISE_TOOL_INSTALL_PATH/init.zsh (e.g. zoxide) with runtime
  # hooks, aliases, functions, key bindings. Source once per shell; individual
  # scripts are expected to be idempotent OR guard their own hooks.
  typeset -gA __mise_init_sourced
  local initfile
  while IFS= read -r install_path; do
    initfile="$install_path/init.zsh"
    [[ -f "$initfile" ]] || continue
    (( ${+__mise_init_sourced[$initfile]} )) && continue
    source "$initfile"
    __mise_init_sourced[$initfile]=1
  done < "$cache_file"

  # --- Man pages: update MANPATH ---
  # Rebuild manpath: drop stale mise dirs, add active ones
  # (no deregister step needed -- man searches MANPATH dynamically)

#  for dir in "${manpath[@]}"; do
#    [[ "$dir" != "${mise_data_dir}/installs"* && -n "$dir" ]] && new_manpath+=("$dir")
#  done
#  for dir in "${active_man_dirs[@]}"; do
#    (( ${new_manpath[(Ie)$dir]} )) || new_manpath+=("$dir")
#  done
#  manpath=("${new_manpath[@]}")
}

if [[ -o interactive ]]; then
  # zim-mise sources mise-activate.zsh which resets __MISE_ZSH_CHPWD_RAN=0
  # and installs a precmd hook that re-runs `mise hook-env` (~40ms). Since
  # mise-activate.zsh already ran `_mise_hook` at source-time and we haven't
  # changed directory since, pretend chpwd already fired so the first precmd
  # short-circuits. Saves ~40ms on every shell startup.
  [[ -n $MISE_SHELL ]] && export __MISE_ZSH_CHPWD_RAN=1

  __mise_extras_initialized=0
  __init_mise_extras_once() {
    if (( __mise_extras_initialized == 0 && ${+functions[compdef]} )); then
      __load_mise_extras
      __mise_extras_initialized=1
      add-zsh-hook -d precmd __init_mise_extras_once
    fi
  }
  add-zsh-hook precmd __init_mise_extras_once
  add-zsh-hook -Uz chpwd __load_mise_extras
fi
