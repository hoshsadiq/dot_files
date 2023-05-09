gh-get-latest-release() {
  repo="$1"
  endswith="$2"

  curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | jq --arg ending "$endswith" -r '.assets[] | select(.name | endswith($ending)).browser_download_url'
}

zinit lucid wait light-mode as"program" from"gh-r" for \
    atclone"./gh_*/bin/gh completion -s zsh > _gh; mv gh*/share/man/man1/gh* $ZPFX/share/man/man1" atpull"%atclone" bpick'*_linux_amd64.tar.gz' pick"gh_*/bin/gh" @cli/cli \
