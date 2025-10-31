#!/bin/bash
# Shell Setup Module
# Installs and configures zsh, oh-my-zsh, and essential plugins

set -e

echo "🐚 [SHELL] Starting shell setup..."

# Install zsh
echo "📦 Installing zsh..."
sudo apt install -y zsh

# Install oh-my-zsh
echo "🎨 Installing oh-my-zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✅ oh-my-zsh already installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ oh-my-zsh installed"
fi

# Install zsh-autosuggestions
echo "💡 Installing zsh-autosuggestions..."
AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$AUTOSUGGESTIONS_DIR" ] && [ -f "$AUTOSUGGESTIONS_DIR/zsh-autosuggestions.zsh" ]; then
    echo "✅ zsh-autosuggestions already installed"
else
    if [ -d "$AUTOSUGGESTIONS_DIR" ]; then
        echo "⚠️  Directory exists but plugin incomplete, removing and reinstalling..."
        rm -rf "$AUTOSUGGESTIONS_DIR"
    fi
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
    echo "✅ zsh-autosuggestions installed"
fi

# Install zsh-syntax-highlighting
echo "🌈 Installing zsh-syntax-highlighting..."
SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ -d "$SYNTAX_DIR" ] && [ -f "$SYNTAX_DIR/zsh-syntax-highlighting.zsh" ]; then
    echo "✅ zsh-syntax-highlighting already installed"
else
    if [ -d "$SYNTAX_DIR" ]; then
        echo "⚠️  Directory exists but plugin incomplete, removing and reinstalling..."
        rm -rf "$SYNTAX_DIR"
    fi
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_DIR"
    echo "✅ zsh-syntax-highlighting installed"
fi

# Set zsh as default shell
echo "🔧 Setting zsh as default shell..."
if [ "$(basename "$SHELL")" != "zsh" ]; then
    sudo chsh -s $(which zsh) $USER
    echo "✅ Default shell changed to zsh"
else
    echo "✅ zsh is already the default shell"
fi

echo "✅ [SHELL] Shell setup complete!"
