# Manage zsh completions and man pages for mise-installed tools.
# Runs once at first prompt (after compinit), then on directory change.
#
# Active versions come from PATH, which mise's hook-env rewrites on every cd,
# so it already reflects the current directory. The cache stores what each
# install ships (its completion files), keyed per install dir and rebuilt when
# that dir's mtime changes.

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
  local install_path real rel tool target record_type initfile compfile line cmd kind funcname content mtime
  local mise_data_dir installs_dir cache_dir cache_file tmp
  local tab=$'\t'
  local changed=0 bashcompinit_loaded=0
  local -a active_installs active_comp_dirs new_fpath lines meta_lines fields
  local -A meta seen

  command -v mise &>/dev/null || return 0
  [[ -o interactive ]] || return 0
  (( ${+functions[compdef]} )) || return 0
  zmodload -F zsh/stat b:zstat 2>/dev/null

  mise_data_dir="${MISE_DATA_DIR:-${HOME}/.local/share/mise}"
  installs_dir="${mise_data_dir}/installs"
  cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"
  cache_file="${cache_dir}/mise-tools.tsv"

  # PATH entries look like <installs>/<tool>/<version>[/<subdir>]. Keep the
  # first two parts, then resolve a version alias (`latest`, `2`, ...) one level
  # to its concrete version, but only if the target stays inside that tool's own
  # dir. Aliases are relative symlinks to a sibling dir, so the key becomes e.g.
  # <installs>/awscli/2.36.46. We stop there: some concrete dirs symlink out to
  # mise/http-tarballs or ~/.cargo (rust), and leaving the path under installs/
  # keeps stale fpath entries matchable by prefix.
  for install_path in ${(s.:.)PATH}; do
    [[ "$install_path" == "${installs_dir}"/*/* ]] || continue
    rel="${install_path#${installs_dir}/}"
    tool="${rel%%/*}"
    real="${installs_dir}/${tool}/${${rel#*/}%%/*}"
    if [[ -L "$real" ]]; then
      target="$(readlink "$real")"
      [[ "$target" != /* ]] && target="${real:h}/${target}"
      target="${target:a}"
      [[ "$target" == "${installs_dir}/${tool}/"* ]] && real="$target"
    fi
    [[ "$real" != *$'\t'* ]] || continue   # a tab would break the cache format
    [[ -n "${seen[$real]}" ]] && continue
    seen[$real]=1
    active_installs+=("$real")
  done

  # One cache file. Each line starts with the record type:
  #   install<TAB><install><TAB><mtime>
  #   compdef<TAB><install><TAB><compfile><TAB><kind><TAB><cmd>
  if [[ -s "$cache_file" ]]; then
    while IFS= read -r line; do
      [[ -n "$line" ]] || continue
      fields=("${(ps.\t.)line}")
      case "$fields[1]" in
        install)
          meta_lines+=("$line")
          meta[$fields[2]]="$fields[3]"
          ;;
        compdef)
          lines+=("$line")
          ;;
      esac
    done < "$cache_file"
  fi

  for real in "${active_installs[@]}"; do
    [[ -d "$real" ]] || continue
    # zsh/stat follows symlinks by default, which catches a relinked `latest`.
    # -L would lstat and miss it.
    mtime=$(zstat +mtime "$real" 2>/dev/null) || continue
    [[ "${meta[$real]}" == "$mtime" ]] && continue

    meta_lines=(${meta_lines:#install${tab}${real}${tab}*})
    lines=(${lines:#compdef${tab}${real}${tab}*})
    if [[ -d "$real/functions" ]]; then
      for compfile in "$real"/functions/_*(N); do
        [[ -f "$compfile" && -r "$compfile" ]] || continue
        [[ "$compfile" != *$'\t'* ]] || continue   # a tab would break the cache format
        content="$(<$compfile)"
        line="${content%%$'\n'*}"
        [[ "$line" == "#compdef "* ]] || continue
        cmd="${line#\#compdef }"
        cmd="${cmd//$'\t'/ }"   # tabs word-split the same way, so spaces are equivalent
        [[ "$cmd" == -* ]] && continue
        [[ "$content" == *'complete -C'* ]] && kind=bash || kind=autoload
        lines+=("compdef${tab}${real}${tab}${compfile}${tab}${kind}${tab}${cmd}")
      done
    fi
    meta_lines+=("install${tab}${real}${tab}${mtime}")
    meta[$real]="$mtime"
    changed=1
  done

  local -a stale_paths
  for install_path in "${(@k)meta}"; do
    [[ -d "$install_path" ]] || stale_paths+=("$install_path")
  done
  for install_path in "${stale_paths[@]}"; do
    unset "meta[$install_path]"
    meta_lines=(${meta_lines:#install${tab}${install_path}${tab}*})
    lines=(${lines:#compdef${tab}${install_path}${tab}*})
    changed=1
  done

  if (( changed )); then
    mkdir -p "$cache_dir"
    # Sorted so an update changes one line instead of reshuffling the file.
    (( ${#meta_lines} )) && meta_lines=("${(@o)meta_lines}")
    (( ${#lines} )) && lines=("${(@o)lines}")
    # One temp file and one rename. Both record types land together, so a
    # concurrent shell can never pair one shell's index with another's rows.
    # mktemp gives each shell its own name, and the file sits next to the
    # target so the rename stays on one filesystem and is atomic.
    tmp="$(mktemp "${cache_file}.XXXXXX" 2>/dev/null)"
    if [[ -n "$tmp" ]]; then
      if (( ${#meta_lines} + ${#lines} )); then
        print -rl -- "${meta_lines[@]}" "${lines[@]}" >| "$tmp"
      else
        : >| "$tmp"
      fi
      mv -f "$tmp" "$cache_file"
    fi
  fi

  for real in "${active_installs[@]}"; do
    [[ -d "$real/functions" ]] && active_comp_dirs+=("$real/functions")
  done

  # Deregister completions from stale mise dirs. Only fires on chpwd, when the
  # active set has changed; at startup fpath has no mise install paths yet.
  for install_path in "${fpath[@]}"; do
    [[ "$install_path" == "${installs_dir}"/* ]] || continue
    (( ${active_comp_dirs[(Ie)$install_path]} )) && continue
    for compfile in "$install_path"/_*(N); do
      [[ -f "$compfile" && -r "$compfile" ]] || continue
      read -r line < "$compfile" 2>/dev/null || continue
      [[ "$line" == "#compdef "* ]] || continue
      cmd="${line#\#compdef }"
      cmd="${cmd//$'\t'/ }"
      cmd="${cmd%% *}"          # first command only
      compdef -d "$cmd" 2>/dev/null
    done
  done

  for install_path in "${fpath[@]}"; do
    [[ "$install_path" != "${installs_dir}"* ]] && new_fpath+=("$install_path")
  done
  for install_path in "${active_comp_dirs[@]}"; do
    (( ${new_fpath[(Ie)$install_path]} )) || new_fpath+=("$install_path")
  done
  fpath=("${new_fpath[@]}")

  [[ -s "$cache_file" ]] && while IFS=$'\t' read -r record_type install_path compfile kind cmd; do
    [[ "$record_type" == compdef && -n "${seen[$install_path]}" ]] || continue
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
  done < "$cache_file"

  # Tools may ship $MISE_TOOL_INSTALL_PATH/init.zsh (e.g. zoxide) with runtime
  # hooks, aliases, functions, or key bindings. Source each once per shell; the
  # scripts are expected to be idempotent or to guard their own hooks.
  typeset -gA __mise_init_sourced
  for real in "${active_installs[@]}"; do
    initfile="$real/init.zsh"
    [[ -f "$initfile" ]] || continue
    (( ${+__mise_init_sourced[$initfile]} )) && continue
    source "$initfile"
    __mise_init_sourced[$initfile]=1
  done
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
