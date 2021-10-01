_zsh_asdf_install_all_tools() {
  local current_plugins new_plugins plugins_to_add plugins_to_remove plugin

  current_plugins=("${(@f)$(asdf plugin list | sort -u)}")
  new_plugins=("${(@f)$(cut -d' ' -f1 "$HOME/dot_files/dots/.tool-versions" | sort -u)}")

  plugins_to_add=("${(@f)$(comm -23 <(printf "%s\n" "${new_plugins[@]}") <(printf "%s\n" "${current_plugins[@]}"))}")
  plugins_to_remove=("${(@f)$(comm -23 <(printf "%s\n" "${current_plugins[@]}") <(printf "%s\n" "${new_plugins[@]}"))}")

  for plugin in "${plugins_to_add[@]}"; do
    asdf plugin add "$plugin"
  done

  for plugin in "${plugins_to_remove[@]}"; do
    asdf plugin remove "$plugin"
  done

  while read -r tool version; do
    asdf install "$tool" "$version"
    asdf global "$tool" "$version"
  done <"$HOME/dot_files/dots/.tool-versions"

  asdf current direnv && source <(asdf exec direnv hook zsh)

  unfunction _zsh_asdf_install_all_tools
}

zinit ice ver'v0.8.0' src'asdf.sh' mv'completions/_asdf -> .' atclone'_zsh_asdf_install_all_tools' atpull"%atclone" atinit'zpcompinit -q; zpcdreplay -q'
zinit light asdf-vm/asdf
