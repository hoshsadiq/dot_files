#!/usr/bin/env bash

extensionIds=(\
  1707051 \ # 1Password X
  1705979 \ # Decentraleyes
  909656  \ # Don't touch my tabs
  1720369 \ # DuckDuckGo Hide Unwanted results
  1669416 \ # HTTPS Everywhere
  1119197 \ # Make Medium Readable Again
  1062944 \ # Privacy Possum
  1676938 \ # Reddit Enhancement Suite
  1249561 \ # Redirect AMP to HTML
  1726419 \ # Refined Github
  1725626 \ # Ublock Origin
  1706559 \ # Violentmonkey
  # todo missing Privacy Budget and Hacker News Enhancement Suite
)

curl -fsSL -o /tmp/firefox-extension-manager https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/mozilla/firefox-extension-manager
chmod +x /tmp/firefox-extension-manager

/tmp/firefox-extension-manager --install "https://addons.mozilla.org/firefox/downloads/file/$id/"
