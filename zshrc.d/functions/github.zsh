gh-get-latest-release() {
  repo="$1"
  endswith="$2"

  curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | jq --arg ending "$endswith" -r '.assets[] | select(.name | endswith($ending)).browser_download_url'
}
