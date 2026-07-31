#!/bin/bash
set -euo pipefail

DOT_FILES="${DOT_FILES:-$HOME/dot_files}"
PI_CONFIG="$DOT_FILES/config/pi"
PI_DIR="$HOME/.pi"

mkdir -p "$PI_DIR/agent/extensions"

ln -sf "$PI_CONFIG/agent/settings.json" "$PI_DIR/agent/settings.json"
ln -sf "$PI_CONFIG/agent/agents-team.json" "$PI_DIR/agent/agents-team.json"

if [ -L "$PI_DIR/agent/skills" ]; then
	rm "$PI_DIR/agent/skills"
elif [ -d "$PI_DIR/agent/skills" ]; then
	echo "~/.pi/agent/skills/ exists as a real directory. Back it up and remove it first." >&2
	exit 1
fi
ln -s "$PI_CONFIG/agent/skills" "$PI_DIR/agent/skills"

mise install "npm:@earendil-works/pi-coding-agent" "github:yvgude/lean-ctx"

pi install npm:pi-agents-team
pi install npm:pi-auto-router
pi install npm:pi-lean-ctx
pi install npm:@gotgenes/pi-anthropic-auth

ln -sfn "$PI_CONFIG/agent/extensions/provider-whitelist" "$PI_DIR/agent/extensions/provider-whitelist"
ln -sfn "$PI_CONFIG/agent/extensions/mac-system-theme" "$PI_DIR/agent/extensions/mac-system-theme"

# Override built-in dark/light themes with Catppuccin so pi boots with correct
# colours (avoids flash of default theme before custom theme loads).
# These get overwritten on pi updates, so this runs on every setup.
PI_BUILTIN_THEMES="$(dirname "$(dirname "$(readlink -f "$(which pi)")")")/dist/modes/interactive/theme"
if [ -d "$PI_BUILTIN_THEMES" ]; then
	jq '.name = "dark"' "$PI_CONFIG/agent/themes/catppuccin-mocha.json" > "$PI_BUILTIN_THEMES/dark.json"
	jq '.name = "light"' "$PI_CONFIG/agent/themes/catppuccin-latte.json" > "$PI_BUILTIN_THEMES/light.json"
fi

# Symlink custom catppuccin themes for the auto format ("latte/mocha")
mkdir -p "$PI_DIR/agent/themes"
ln -sf "$PI_CONFIG/agent/themes/catppuccin-mocha.json" "$PI_DIR/agent/themes/catppuccin-mocha.json"
ln -sf "$PI_CONFIG/agent/themes/catppuccin-latte.json" "$PI_DIR/agent/themes/catppuccin-latte.json"
ln -sf "$PI_CONFIG/agent/extensions/auto-router.routes.json" "$PI_DIR/agent/extensions/auto-router.routes.json"
mkdir -p "$PI_DIR/agent/extensions/pi-lean-ctx"
ln -sf "$PI_CONFIG/agent/extensions/pi-lean-ctx/config.json" "$PI_DIR/agent/extensions/pi-lean-ctx/config.json"

mkdir -p "$HOME/.config/lean-ctx"
ln -sf "$DOT_FILES/config/lean-ctx/config.toml" "$HOME/.config/lean-ctx/config.toml"

echo "Done. Run 'pi' then '/login' to authenticate."
