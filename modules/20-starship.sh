#!/bin/bash
# Starship Prompt Module
# Installs and configures Starship prompt

set -e

echo "⭐ [STARSHIP] Starting Starship setup..."

# Install Starship
echo "📦 Installing Starship prompt..."
if command -v starship &> /dev/null; then
    echo "✅ Starship already installed ($(starship --version))"
    export STARSHIP_INSTALLED=true
elif curl -sS https://starship.rs/install.sh | sh -s -- -y; then
    echo "✅ Starship installed successfully"
    export STARSHIP_INSTALLED=true
else
    echo "⚠️  Starship installation failed. Will use oh-my-zsh themes instead."
    export STARSHIP_INSTALLED=false
fi

# Configure Starship with tokyo-night preset (only if config doesn't exist in repo)
if [ "$STARSHIP_INSTALLED" = true ]; then
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    # Check if starship.toml exists in repo's dotfiles
    if [ -f "$REPO_DIR/dotfiles/starship.toml" ]; then
        echo "✅ Starship config found in repo at dotfiles/starship.toml"
        echo "   (will be restored by restore script if needed)"
    else
        # Only create default config if user doesn't have one AND repo doesn't have one
        if [ ! -f ~/.config/starship.toml ]; then
            echo "🎨 Configuring Starship with tokyo-night preset..."
            mkdir -p ~/.config
            starship preset tokyo-night -o ~/.config/starship.toml
            echo "✅ Starship configured with tokyo-night theme"
        else
            echo "⚠️  Starship config already exists at ~/.config/starship.toml - preserving existing config"
        fi
    fi
fi

echo "✅ [STARSHIP] Starship setup complete!"
