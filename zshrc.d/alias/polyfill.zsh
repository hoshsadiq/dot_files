# macOS has no `md5sum` and `sha1sum`, so fallback on `md5` and `shasum`
if [[ "$OSTYPE" == darwin* ]]; then
    command -v md5sum &>/dev/null || alias md5sum="md5"
    command -v sha1sum &>/dev/null || alias sha1sum="shasum"
fi

if ! command -v firefox &>/dev/null; then
  alias firefox="open -a Firefox"
fi

if command -v xdg-open &>/dev/null; then
  alias open="xdg-open"
fi

if command -v intellij-idea-ultimate &>/dev/null; then
  alias idea="intellij-idea-ultimate"
fi
