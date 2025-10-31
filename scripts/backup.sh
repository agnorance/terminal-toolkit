#!/bin/bash
# Backup Dotfiles Script
# Saves current dotfiles to the repo's dotfiles directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

echo "💾 Backing up dotfiles to repo..."
echo ""

# Ensure dotfiles directory exists
mkdir -p "$DOTFILES_DIR"

# Track what was backed up
BACKED_UP=()
NOT_FOUND=()

# Backup .zshrc
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc "$DOTFILES_DIR/.zshrc"
    BACKED_UP+=(".zshrc")
else
    NOT_FOUND+=(".zshrc")
fi

# Backup .gitconfig
if [ -f ~/.gitconfig ]; then
    cp ~/.gitconfig "$DOTFILES_DIR/.gitconfig"
    BACKED_UP+=(".gitconfig")
else
    NOT_FOUND+=(".gitconfig")
fi

# Backup .vimrc
if [ -f ~/.vimrc ]; then
    cp ~/.vimrc "$DOTFILES_DIR/.vimrc"
    BACKED_UP+=(".vimrc")
else
    NOT_FOUND+=(".vimrc")
fi

# Backup starship.toml
if [ -f ~/.config/starship.toml ]; then
    cp ~/.config/starship.toml "$DOTFILES_DIR/starship.toml"
    BACKED_UP+=("starship.toml")
else
    NOT_FOUND+=("starship.toml")
fi

# Backup tmux config if it exists
if [ -f ~/.tmux.conf ]; then
    cp ~/.tmux.conf "$DOTFILES_DIR/.tmux.conf"
    BACKED_UP+=(".tmux.conf")
fi

# Display results
if [ ${#BACKED_UP[@]} -gt 0 ]; then
    echo "✅ Backed up ${#BACKED_UP[@]} file(s):"
    for file in "${BACKED_UP[@]}"; do
        echo "   ✓ $file"
    done
fi

if [ ${#NOT_FOUND[@]} -gt 0 ]; then
    echo ""
    echo "⊘ Not found (skipped):"
    for file in "${NOT_FOUND[@]}"; do
        echo "   - $file"
    done
fi

echo ""
echo "📁 Dotfiles saved to: $DOTFILES_DIR"
echo ""
echo "💡 Next steps:"
echo "   cd $SCRIPT_DIR"
echo "   git add dotfiles/"
echo "   git commit -m 'Update dotfiles'"
echo "   git push"
