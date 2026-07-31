#!/bin/bash
set -euo pipefail

PI_DIR="$HOME/.pi"

rm -f "$PI_DIR/agent/settings.json"
rm -f "$PI_DIR/agent/agents-team.json"
rm -f "$PI_DIR/agent/skills"
rm -f "$PI_DIR/agent/extensions/provider-whitelist"
rm -f "$PI_DIR/agent/extensions/auto-router.routes.json"
rm -f "$PI_DIR/agent/extensions/pi-lean-ctx/config.json"
rm -f "$HOME/.config/lean-ctx/config.toml"

if command -v pi &>/dev/null; then
	pi uninstall npm:pi-agents-team 2>/dev/null || true
	pi uninstall npm:pi-auto-router 2>/dev/null || true
	pi uninstall npm:pi-lean-ctx 2>/dev/null || true
fi

echo "Symlinks and extensions removed. ~/.pi/agent/ dir preserved (sessions, auth)."
echo "To fully remove: rm -rf ~/.pi"
