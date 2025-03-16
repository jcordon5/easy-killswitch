#!/bin/bash

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="killswitch"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"
SOURCE_SCRIPT="killswitch.sh"

echo "🔧 Installing easy-killswitch for macOS..."

if [[ $EUID -ne 0 ]]; then
    echo "❌ This installer needs to be run as root (sudo)."
    exit 1
fi

if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "📁 Creating $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
fi

echo "📄 Copying $SCRIPT_NAME to $INSTALL_DIR..."
cp "$SOURCE_SCRIPT" "$SCRIPT_PATH"

echo "🔑 Setting execution permissions..."
chmod +x "$SCRIPT_PATH"

if ! sudo pfctl -s info | grep -q "Status: Enabled"; then
    echo "⚠️  pf is currently disabled. You may need to enable it manually using: sudo pfctl -E"
fi

read -p "🔗 Do you want to add 'killswitch' as a command? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    SHELL_PROFILE=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_PROFILE="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_PROFILE="$HOME/.bashrc"
    fi

    if [[ -n "$SHELL_PROFILE" ]]; then
        echo "alias killswitch=sudo '$SCRIPT_PATH'" >> "$SHELL_PROFILE"
        echo "✅ Alias added to $SHELL_PROFILE. Restart your terminal or run 'source $SHELL_PROFILE' to apply changes."
    else
        echo "⚠️  Could not detect your shell profile. Manually add this line to your shell config:"
        echo "alias killswitch=sudo '$SCRIPT_PATH'"
    fi
fi

echo "🎉 Installation complete! You can now use 'killswitch' anywhere in the terminal."
echo "Run 'killswitch --help' for options."
