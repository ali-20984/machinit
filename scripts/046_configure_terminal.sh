#!/bin/bash
#
# Script: 046_configure_terminal.sh
# Description: Configure Terminal
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_config "Terminal Theme"

# Determine theme choice from config (fall back to 'shades_of_fire')
THEME_NAME=$(get_config "appearance.terminal_theme")
if [ -z "$THEME_NAME" ]; then
    THEME_NAME="shades_of_fire"
fi

# Only use UTF-8 in Terminal.app
# -array is complex for set_default, using raw defaults write
defaults write com.apple.terminal StringEncodings -array 4

# Enable Secure Keyboard Entry in Terminal.app
# See: https://security.stackexchange.com/a/47786/8918
set_default com.apple.terminal SecureKeyboardEntry bool true

# Don’t display the annoying prompt when quitting iTerm
set_default com.googlecode.iterm2 PromptOnQuit bool false

# Use AppleScript to configure the default Terminal profile
# Colors are in 16-bit RGB (0-65535)
# Black: {0, 0, 0}
# Pale Red: {65535, 30000, 30000} (approx)

osascript <<EOD
tell application "Terminal"
    try
        set defaultSettings to default settings
        
        tell defaultSettings
            -- Configure palette for the currently selected THEME_NAME
            if ("${THEME_NAME}" = "shades_of_fire") then
                -- Shades of Fire palette (warm dark background + fiery accents)
                -- background: deep charcoal
                set background color to {2500, 1500, 800}
                -- regular text: whiteish (bright, for clear contrast in Shades of Fire)
                set normal text color to {62000, 62000, 63000}
                -- bold text: bright orange / flame
                set bold text color to {65535, 36000, 14000}
                -- cursor: bright ember
                set cursor color to {65535, 43000, 20000}
                set transparency to 0.03 -- 97% opacity
            else
                -- Charcoal (neutral darker background) fallback
                set background color to {2000, 2000, 2000}
                set normal text color to {62000, 62000, 62000}
                set bold text color to {62000, 62000, 62000}
                set cursor color to {52000, 52000, 52000}
                set transparency to 0.00
            end if
            
            -- Set Font (Fantasque Sans Mono)
            -- Note: The font must be installed for this to work.
            set font name to "FantasqueSansMono-Regular"
            set font size to 13
        end tell
        
        -- Apply to all open windows
        repeat with w in windows
            set current settings of w to defaultSettings
        end repeat
        
    on error errMsg
        log "Error setting terminal theme: " & errMsg
    end try
end tell
EOD

# Configure shell prompt (Zsh) for a 'Shades of Fire' look
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    # Insert a clearly marked block so it's easy to find/replace later
    if [ "${THEME_NAME}" = "shades_of_fire" ]; then
        if ! grep -q "# Shades of Fire prompt" "$ZSHRC"; then
                    cat >>"$ZSHRC" <<'EOF'
                    # Shades of Fire prompt (user/folder in warm ember tones)
                    # Username: bright orange; arrow: red; current dir: warm yellow
                    export PROMPT='%F{202}%n%f %F{196}➜%f %F{220}%~%f '
EOF
        fi
    else
        # Charcoal prompt (neutral tone)
        if ! grep -q "# Charcoal prompt" "$ZSHRC"; then
                    cat >>"$ZSHRC" <<'EOF'
                    # Charcoal prompt (neutral minimal prompt)
                    export PROMPT='%n %F{250}➜%f %~ '
EOF
        fi
    fi
fi

echo "Terminal theme configured (${THEME_NAME})."
