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
  local install_path functions_dir man_dir mise_data_dir tool_json
  local -a active_comp_dirs active_man_dirs new_fpath new_manpath
  local dir compfile line cmd

  command -v mise &>/dev/null || return 0
  [[ -o interactive ]] || return 0
  (( ${+functions[compdef]} )) || return 0

  mise_data_dir="${MISE_DATA_DIR:-${HOME}/.local/share/mise}"

  # Collect functions/ and man dirs from active tool installs
  while IFS= read -r tool_json; do
    install_path=$(printf '%s' "$tool_json" | jq -r '.install_path // empty' 2>/dev/null)
    [[ -n "$install_path" && -d "$install_path" ]] || continue

    functions_dir="$install_path/functions"
    [[ -d "$functions_dir" ]] && active_comp_dirs+=("$functions_dir")

    for man_dir in "$install_path"/share/man "$install_path"/man; do
      if [[ -d "$man_dir" ]]; then
        active_man_dirs+=("$man_dir")
        break
      fi
    done
  done < <(mise list --json 2>/dev/null | jq -c '.[] | .[] | select(.active == true)' 2>/dev/null)

  # --- Completions: update fpath ---

  # Deregister completions from stale mise dirs no longer active
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

  # Register completions (compinit already ran)
  local bashcompinit_loaded=0
  for dir in "${active_comp_dirs[@]}"; do
    for compfile in "$dir"/_*(N); do
      [[ -f "$compfile" && -r "$compfile" ]] || continue
      read -r line < "$compfile" 2>/dev/null || continue
      [[ "$line" == "#compdef "* ]] || continue

      cmd="${line#\#compdef }"
      # skip compdef flags (-p, -P, etc.)
      [[ "$cmd" == -* ]] && continue

      if grep -q 'complete -C' "$compfile" 2>/dev/null; then
        # bash-style completion (e.g. awscli)
        if (( ! bashcompinit_loaded )); then
          autoload -Uz bashcompinit && bashcompinit 2>/dev/null
          bashcompinit_loaded=1
        fi
        source "$compfile"
      else
        autoload -Uz "${compfile:t}"
        # word-splitting intentional: multi-command headers like "#compdef kubectx kctx=kubectx"
        compdef "${compfile:t}" ${=cmd}
      fi
    done
  done

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
