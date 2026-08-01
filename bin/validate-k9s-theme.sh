#!/usr/bin/env bash
set -euo pipefail

echo "=== k9s Theme Validation ==="
echo

# Check current macOS appearance
if defaults read -g AppleInterfaceStyle &>/dev/null; then
    EXPECTED_THEME="dark"
    EXPECTED_SKIN="catppuccin-mocha"
else
    EXPECTED_THEME="light"
    EXPECTED_SKIN="catppuccin-latte"
fi

echo "1. macOS Appearance Detection:"
echo "   Current system theme: $EXPECTED_THEME"
echo "   Expected k9s skin: $EXPECTED_SKIN"
echo

# Detect k9s config directory
K9S_CONFIG_FILE=""
if command -v k9s &>/dev/null; then
    if k9s info 2>/dev/null | grep -q "^Config:"; then
        K9S_CONFIG_FILE=$(k9s info 2>/dev/null | grep "^Config:" | awk '{print $2}' | head -1)
    fi
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
        K9S_CONFIG_FILE="$HOME/Library/Application Support/k9s/config.yaml"
    fi
fi

echo "2. k9s Config File:"
echo "   Detected config location: $K9S_CONFIG_FILE"
if [[ -f "$K9S_CONFIG_FILE" ]]; then
    echo "   ✓ Config file exists: $K9S_CONFIG_FILE"
    
    # Try to read skin with jq
    if command -v jq &>/dev/null; then
        CURRENT_SKIN=$(jq --yaml-input -r '.k9s.ui.skin // "not set"' "$K9S_CONFIG_FILE" 2>/dev/null || echo "error reading")
        echo "   Current skin in config: $CURRENT_SKIN"
        
        if [[ "$CURRENT_SKIN" == "$EXPECTED_SKIN" ]]; then
            echo "   ✓ Skin matches expected theme!"
        else
            echo "   ✗ Skin mismatch! Expected: $EXPECTED_SKIN"
        fi
    else
        echo "   ⚠ Cannot read YAML (need jq)"
        echo "   Config file contents:"
        cat "$K9S_CONFIG_FILE" | sed 's/^/      /'
    fi
else
    echo "   ✗ Config file does not exist: $K9S_CONFIG_FILE"
    echo "   Run the theme switcher script to create it"
fi
echo

# Check if skins directory exists
K9S_CONFIG_DIR=$(dirname "$K9S_CONFIG_FILE")
K9S_SKINS_DIR="$K9S_CONFIG_DIR/skins"
K9S_DOTFILES_SKINS_DIR="$HOME/dot_files/config/k9s/skins"
echo "3. k9s Skins:"
if [[ -d "$K9S_DOTFILES_SKINS_DIR" ]]; then
    echo "   ✓ Dotfiles skins directory exists: $K9S_DOTFILES_SKINS_DIR"
    SKIN_COUNT=$(find "$K9S_DOTFILES_SKINS_DIR" -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')
    echo "   Found $SKIN_COUNT skin file(s)"
    
    if [[ -d "$K9S_SKINS_DIR" ]]; then
        echo "   ✓ k9s skins directory exists: $K9S_SKINS_DIR"
        LINKED_COUNT=$(find "$K9S_SKINS_DIR" -type l 2>/dev/null | wc -l | tr -d ' ')
        echo "   Found $LINKED_COUNT symlinked skin(s)"
    else
        echo "   ⚠ k9s skins directory does not exist (will be created by switcher)"
    fi
else
    echo "   ⚠ Dotfiles skins directory does not exist: $K9S_DOTFILES_SKINS_DIR"
    echo "   Note: Script will fall back to built-in skins if this doesn't exist"
fi
echo

# Check theme switcher script
THEME_SWITCHER="$HOME/dot_files/bin/alacritty-theme-switcher.sh"
echo "4. Theme Switcher Script:"
if [[ -f "$THEME_SWITCHER" ]]; then
    echo "   ✓ Script exists: $THEME_SWITCHER"
    if [[ -x "$THEME_SWITCHER" ]]; then
        echo "   ✓ Script is executable"
    else
        echo "   ⚠ Script is not executable (chmod +x needed)"
    fi
else
    echo "   ✗ Script not found: $THEME_SWITCHER"
fi
echo

# Check LaunchAgent
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.alacritty.theme-switcher.plist"
echo "5. LaunchAgent:"
if [[ -f "$LAUNCH_AGENT" ]]; then
    echo "   ✓ LaunchAgent exists: $LAUNCH_AGENT"
    
    # Check if it's loaded
    if launchctl list 2>/dev/null | grep -q "com.alacritty.theme-switcher"; then
        echo "   ✓ LaunchAgent is loaded"
    else
        echo "   ⚠ LaunchAgent exists but may not be loaded"
        echo "   Run: launchctl load $LAUNCH_AGENT"
    fi
else
    echo "   ⚠ LaunchAgent not found (script may run manually)"
fi
echo

# Test run the switcher
echo "6. Testing Theme Switcher:"
echo "   Running theme switcher script..."
if bash "$THEME_SWITCHER" 2>&1 | grep -q "k9s\|Switched"; then
    echo "   ✓ Script ran and mentioned k9s"
    bash "$THEME_SWITCHER" 2>&1 | grep -i k9s || echo "   (no k9s output - may not have changed)"
else
    echo "   ⚠ Script ran but no k9s output detected"
    echo "   Full output:"
    bash "$THEME_SWITCHER" 2>&1 | sed 's/^/      /'
fi
echo

# Final validation
echo "7. Final Check:"
if [[ -n "$K9S_CONFIG_FILE" ]] && [[ -f "$K9S_CONFIG_FILE" ]]; then
    if command -v jq &>/dev/null; then
        FINAL_SKIN=$(jq --yaml-input -r '.k9s.ui.skin // "not set"' "$K9S_CONFIG_FILE" 2>/dev/null || echo "error")
    else
        FINAL_SKIN="unknown (jq not found)"
    fi
    
    echo "   Current k9s skin: $FINAL_SKIN"
    echo "   Expected skin: $EXPECTED_SKIN"
    
    if [[ "$FINAL_SKIN" == "$EXPECTED_SKIN" ]]; then
        echo "   ✅ SUCCESS: k9s theme is correctly configured!"
    else
        echo "   ❌ MISMATCH: Theme may need manual update"
    fi
else
    echo "   ⚠ Config file doesn't exist - run theme switcher first"
fi
echo

echo "=== Validation Complete ==="
echo
echo "To test theme switching:"
echo "  1. Change macOS appearance (System Settings > Appearance)"
echo "  2. Wait ~30 seconds for LaunchAgent, or run: $THEME_SWITCHER"
echo "  3. Run this script again to verify"
echo "  4. Launch k9s and verify the theme visually"
