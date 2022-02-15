_zsh_asdf_install_all_tools() {
  local current_plugins new_plugins plugins_to_add plugins_to_remove plugin tool version

  current_plugins=("${(@f)$(asdf plugin list | sort -u)}")
  new_plugins=("${(@f)$(cut -d' ' -f1 "$HOME/dot_files/dots/tool-versions" | sort -u)}")

  plugins_to_add=("${(@f)$(comm -23 <(printf "%s\n" "${new_plugins[@]}") <(printf "%s\n" "${current_plugins[@]}"))}")
  plugins_to_remove=("${(@f)$(comm -23 <(printf "%s\n" "${current_plugins[@]}") <(printf "%s\n" "${new_plugins[@]}"))}")

  for plugin in "${plugins_to_add[@]}"; do
    if [[ -n $plugin ]]; then
      asdf plugin add "$plugin"
    fi
  done

  for plugin in "${plugins_to_remove[@]}"; do
    if [[ -n $plugin ]]; then
      asdf plugin remove "$plugin"
    fi
  done

  while read -r tool version; do
    asdf install "$tool" "$version"
    asdf global "$tool" "$version"
  done <"$HOME/dot_files/dots/tool-versions"

  # shellcheck disable=SC1090
  if asdf current direnv >/dev/null; then
    source <(asdf exec direnv hook zsh)
  fi
}

_zsh_asdf_load() {
  trap 'unfunction _zsh_asdf_load _zsh_asdf_install_all_tools' EXIT;

  # shellcheck disable=SC1090
  if asdf current direnv >/dev/null; then
    source <(asdf exec direnv hook zsh)
  fi

  source "$HOME/.asdf/plugins/java/set-java-home.zsh"

  zpcompinit -q
  zpcdreplay -q
}

direnv() {
  asdf exec direnv "$@"
}

zinit ice ver'v0.9.0' src'asdf.sh' mv'completions/_asdf -> .' atclone'_zsh_asdf_install_all_tools' atpull"%atclone" atload'_zsh_asdf_load'
zinit light asdf-vm/asdf
