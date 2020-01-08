#!/usr/bin/env bash

mkdir -p "$HOME/apps/qemu-img"
curl -fsSL https://cloudbase.it/downloads/qemu-img-win-x64-2_3_0.zip -o /tmp/qemu-img-win.zip
unzip -o -d "$HOME/apps/qemu-img" /tmp/qemu-img-win.zip
chmod +x "$HOME/apps/qemu-img/"*

if ! grep -qF '$HOME/apps/qemu-img' $HOME/.zshrc.local; then
    cat <<'EOF' >> $HOME/.zshrc.local
    # qemu-img for windows
    addpath "$HOME/apps/qemu-img" after
EOF
fi
