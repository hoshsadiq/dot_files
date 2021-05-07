gh-get-latest-release() {
  repo="$1"
  endswith="$2"

  curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | jq --arg ending "$endswith" -r '.assets[] | select(.name | endswith($ending)).browser_download_url'
}

zinit ice wait silent as"command" from"gh-r" pick"gh_*/bin/gh" bpick"*$(get-os)_$(get-arch).tar.gz" atclone'./**/gh completion --shell zsh > _gh' atpull'%atclone'
zinit light cli/cli
