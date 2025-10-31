#!/bin/bash
# Restore Dotfiles Script
# Restores dotfiles from the repo to your home directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

echo "♻️  Restoring dotfiles from repo..."
echo ""

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Error: No dotfiles directory found at $DOTFILES_DIR"
    echo "   Run ./scripts/backup.sh first to create initial backup"
    exit 1
fi

# Track what was restored
RESTORED=()
NOT_FOUND=()

# Restore .zshrc
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    cp "$DOTFILES_DIR/.zshrc" ~/.zshrc
    RESTORED+=(".zshrc")
else
    NOT_FOUND+=(".zshrc")
fi

# Restore .gitconfig
if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    cp "$DOTFILES_DIR/.gitconfig" ~/.gitconfig
    RESTORED+=(".gitconfig")
else
    NOT_FOUND+=(".gitconfig")
fi

# Restore .vimrc
if [ -f "$DOTFILES_DIR/.vimrc" ]; then
    cp "$DOTFILES_DIR/.vimrc" ~/.vimrc
    RESTORED+=(".vimrc")
else
    NOT_FOUND+=(".vimrc")
fi

# Restore starship.toml
if [ -f "$DOTFILES_DIR/starship.toml" ]; then
    mkdir -p ~/.config
    cp "$DOTFILES_DIR/starship.toml" ~/.config/starship.toml
    RESTORED+=("starship.toml")
else
    NOT_FOUND+=("starship.toml")
fi

# Restore .tmux.conf if it exists in backup
if [ -f "$DOTFILES_DIR/.tmux.conf" ]; then
    cp "$DOTFILES_DIR/.tmux.conf" ~/.tmux.conf
    RESTORED+=(".tmux.conf")
fi

# Display results
if [ ${#RESTORED[@]} -gt 0 ]; then
    echo "✅ Restored ${#RESTORED[@]} file(s):"
    for file in "${RESTORED[@]}"; do
        echo "   ✓ $file"
    done
fi

if [ ${#NOT_FOUND[@]} -gt 0 ]; then
    echo ""
    echo "⊘ Not found in backup (skipped):"
    for file in "${NOT_FOUND[@]}"; do
        echo "   - $file"
    done
fi

echo ""
echo "✅ Dotfiles restored from: $DOTFILES_DIR"
echo ""
echo "🔄 Run 'exec zsh' or restart your terminal to apply changes"
