#!/bin/bash
echo "Configuring Terminal theme (Matrix Red)..."

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Enable Secure Keyboard Entry in Terminal.app
# See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Use AppleScript to configure the default Terminal profile
# Colors are in 16-bit RGB (0-65535)
# Black: {0, 0, 0}
# Pale Red: {65535, 30000, 30000} (approx)

osascript <<EOD
tell application "Terminal"
    try
        set defaultSettings to default settings
        
        tell defaultSettings
            set background color to {0, 0, 0}
            set normal text color to {55000, 0, 0} -- Matrix Red (Darker)
            set bold text color to {65535, 0, 0} -- Matrix Red (Bright)
            set cursor color to {65535, 0, 0}
            
            -- Set Font (Fantasque Sans Mono)
            -- Note: The font must be installed for this to work.
            set font name to "FantasqueSansMono-Regular"
            set font size to 16
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

echo "Terminal theme configured."
