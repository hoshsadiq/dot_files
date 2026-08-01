#!/usr/bin/env bash
set -euo pipefail

# Detect macOS appearance mode
if defaults read -g AppleInterfaceStyle &>/dev/null; then
    THEME="dark"
else
    THEME="light"
fi

# Set COLORFGBG for apps that read it synchronously (e.g. pi.dev theme detection)
# Dark: fg=15 (white), bg=0 (black). Light: fg=0 (black), bg=15 (white).
if [[ "$THEME" == "dark" ]]; then
    COLORFGBG="15;0"
else
    COLORFGBG="0;15"
fi

# Update tmux environment so new panes/processes inherit the correct value
if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null 2>&1; then
    tmux set-environment -g COLORFGBG "$COLORFGBG"
fi

# Alacritty theme switching
ALACRITTY_DIR="$HOME/dot_files/config/alacritty"
ALACRITTY_LINK="$ALACRITTY_DIR/alacritty.theme.toml"
ALACRITTY_TARGET="$ALACRITTY_DIR/alacritty.$THEME.toml"

CURRENT_ALACRITTY=""
if [[ -L "$ALACRITTY_LINK" ]]; then
    CURRENT_ALACRITTY=$(readlink "$ALACRITTY_LINK")
fi

if [[ "$CURRENT_ALACRITTY" != "$ALACRITTY_TARGET" ]]; then
    ln -sf "$ALACRITTY_TARGET" "$ALACRITTY_LINK"
    touch "$ALACRITTY_DIR/alacritty.toml"
    echo "Switched Alacritty theme to: $THEME"
fi

# Delta (git diff) theme switching
DELTA_DIR="$HOME/dot_files/config/git"
DELTA_LINK="$DELTA_DIR/delta.theme.gitconfig"
DELTA_TARGET="$DELTA_DIR/delta.$THEME.gitconfig"

CURRENT_DELTA=""
if [[ -L "$DELTA_LINK" ]]; then
    CURRENT_DELTA=$(readlink "$DELTA_LINK")
fi

if [[ "$CURRENT_DELTA" != "$DELTA_TARGET" ]]; then
    ln -sf "$DELTA_TARGET" "$DELTA_LINK"
    echo "Switched Delta theme to: $THEME"
fi

# Claude CLI theme switching via ~/.claude.json
CLAUDE_JSON="$HOME/.claude.json"
if [[ -f "$CLAUDE_JSON" ]] && command -v jq &>/dev/null; then
    CURRENT_THEME=$(jq -r '.theme // "none"' "$CLAUDE_JSON")
    if [[ "$CURRENT_THEME" != "$THEME" ]]; then
        TMP_FILE=$(mktemp)
        jq --arg theme "$THEME" '.theme = $theme' "$CLAUDE_JSON" > "$TMP_FILE" && mv "$TMP_FILE" "$CLAUDE_JSON"
        echo "Switched Claude theme to: $THEME"
    fi
fi

# k9s theme switching
if command -v k9s &>/dev/null; then
    # Detect k9s config directory from k9s info output
    K9S_CONFIG_FILE=""
    if k9s info 2>/dev/null | grep -q "^Config:"; then
        K9S_CONFIG_FILE=$(k9s info 2>/dev/null | grep "^Config:" | awk '{print $2}' | head -1)
    fi
    
    # Fallback to common locations if k9s info doesn't work
    if [[ -z "$K9S_CONFIG_FILE" ]] || [[ ! -f "$K9S_CONFIG_FILE" ]]; then
        if [[ -f "$HOME/Library/Application Support/k9s/config.yaml" ]]; then
            K9S_CONFIG_FILE="$HOME/Library/Application Support/k9s/config.yaml"
        elif [[ -f "$HOME/.config/k9s/config.yaml" ]]; then
            K9S_CONFIG_FILE="$HOME/.config/k9s/config.yaml"
        elif [[ -f "$HOME/.k9s/config.yaml" ]]; then
            K9S_CONFIG_FILE="$HOME/.k9s/config.yaml"
        else
            # Default to macOS location if k9s is installed but config doesn't exist yet
            K9S_CONFIG_FILE="$HOME/Library/Application Support/k9s/config.yaml"
        fi
    fi
    
    K9S_CONFIG_DIR=$(dirname "$K9S_CONFIG_FILE")
    K9S_SKINS_DIR="$K9S_CONFIG_DIR/skins"
    K9S_DOTFILES_SKINS_DIR="$HOME/dot_files/config/k9s/skins"
    K9S_SKIN_NAME="catppuccin-$([ "$THEME" == "dark" ] && echo "mocha" || echo "latte")"

    if [[ -d "$K9S_DOTFILES_SKINS_DIR" ]]; then
        mkdir -p "$K9S_SKINS_DIR"
        
        # Ensure skins are available (symlink from dot_files)
        for skin_file in "$K9S_DOTFILES_SKINS_DIR"/*.yaml; do
            if [[ -f "$skin_file" ]]; then
                skin_name=$(basename "$skin_file")
                if [[ ! -e "$K9S_SKINS_DIR/$skin_name" ]]; then
                    ln -sf "$skin_file" "$K9S_SKINS_DIR/$skin_name"
                fi
            fi
        done
    fi
    
    # Update config.yaml to set the skin
    if command -v jq &>/dev/null; then
        mkdir -p "$K9S_CONFIG_DIR"
        CURRENT_K9S_SKIN=$(jq --yaml-input -r '.k9s.ui.skin // "none"' "$K9S_CONFIG_FILE" 2>/dev/null || echo "none")
        if [[ "$CURRENT_K9S_SKIN" != "$K9S_SKIN_NAME" ]]; then
            TMP_FILE=$(mktemp)
            ([[ -f "$K9S_CONFIG_FILE" ]] && cat "$K9S_CONFIG_FILE" || echo "{}") | \
                jq --yaml-input --yaml-output ".k9s = (.k9s // {}) | .k9s.ui = (.k9s.ui // {}) | .k9s.ui.skin = \"$K9S_SKIN_NAME\"" > "$TMP_FILE"
            mv "$TMP_FILE" "$K9S_CONFIG_FILE"
            echo "Switched k9s theme to: $K9S_SKIN_NAME"
        fi
    fi
fi

# Note: Pi.dev automatically detects via built-in dark/light detection (catppuccin overrides in ~/.pi/agent/themes/)
# Note: Bat automatically detects macOS appearance with --theme="auto:system"
# Note: Neovim automatically detects with auto-dark-mode.nvim plugin
