#!/usr/bin/env bash

mkdir -p "$HOME/apps/qemu-img"
curl -fsSL https://cloudbase.it/downloads/qemu-img-win-x64-2_3_0.zip -o /tmp/qemu-img-win.zip
unzip -o -d "$HOME/apps/qemu-img" /tmp/qemu-img-win.zip
chmod +x "$HOME/apps/qemu-img/"*

if ! grep -qF '$HOME/apps/qemu-img' $HOME/.zshrc_local; then
    cat <<EOF >> $HOME/.zshrc_local
    # qemu-img for windows
    export PATH="\$PATH:\$HOME/apps/qemu-img"
EOF
fi
