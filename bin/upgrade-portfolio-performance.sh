#!/usr/bin/env bash

set -euxo pipefail

installDir="$HOME/apps/portfolio-performance"

repo="buchen/portfolio"
platformEnding="-linux.gtk.x86_64.tar.gz"

gpg_key_id="E46E6F8FF02E4C83569084589239277F560C95AC"
gpg_key_short_id="${gpg_key_id:(-16)}"
gpg_key_location=https://github.com/buchen.gpg

tmpdir="$(mktemp -d)" && trap 'rm -rf $tmpdir' EXIT || exit 255
curl -fsSL "$gpg_key_location" | gpg --homedir "$tmpdir" --import 2>&1 | awk "/key $gpg_key_short_id.*imported/" >&2
printf "%s:6:\n" "$gpg_key_id" | gpg --homedir "$tmpdir" --import-ownertrust

cd "$tmpdir"
downloadUrl="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | jq --arg ending "$platformEnding" -r '.assets[] | select(.name | endswith($ending)).browser_download_url')"
curl -fsSL "$downloadUrl" -o "$tmpdir/portfolio-performance.tar.gz"
curl -fsSL "$downloadUrl.asc" -o "$tmpdir/portfolio-performance.tar.gz.asc"

gpg --homedir "$tmpdir" --status-fd 3 --verify "$tmpdir/portfolio-performance.tar.gz.asc" "$tmpdir/portfolio-performance.tar.gz" 3>"$tmpdir/signvalidation"
grep -Eq '^\[GNUPG:] TRUST_(ULTIMATE|FULLY)' "$tmpdir/signvalidation"

rm -rf "$installDir" || true
mkdir -p "$installDir"
tar -xzvf "$tmpdir/portfolio-performance.tar.gz" -C "$installDir" --strip-components=1
ln -fs /home/hosh/dot_files/config/desktop-entries/portfolio-performance.desktop ~/.local/share/applications/
