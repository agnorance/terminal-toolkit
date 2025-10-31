#!/bin/bash
# Modern CLI Tools Module
# Installs modern alternatives: eza, zoxide, fzf, ripgrep, fd-find, bat

set -e

echo "🔧 [MODERN-TOOLS] Starting modern tools setup..."

# Install modern CLI tools
echo "📦 Installing modern CLI tools..."
sudo apt install -y \
    fzf \
    ripgrep \
    fd-find \
    bat \
    zoxide \
    eza

# Verify installations
echo "✅ Verifying installations..."
if command -v eza &> /dev/null; then
    echo "   ✓ eza: $(eza --version | head -1)"
else
    echo "   ✗ eza: not found"
fi

if command -v zoxide &> /dev/null; then
    echo "   ✓ zoxide: $(zoxide --version)"
else
    echo "   ✗ zoxide: not found"
fi

if command -v fzf &> /dev/null; then
    echo "   ✓ fzf: $(fzf --version)"
else
    echo "   ✗ fzf: not found"
fi

if command -v rg &> /dev/null; then
    echo "   ✓ ripgrep: $(rg --version | head -1)"
else
    echo "   ✗ ripgrep: not found"
fi

if command -v fdfind &> /dev/null; then
    echo "   ✓ fd-find: $(fdfind --version)"
else
    echo "   ✗ fd-find: not found"
fi

if command -v batcat &> /dev/null; then
    echo "   ✓ bat: $(batcat --version)"
else
    echo "   ✗ bat: not found"
fi

echo "✅ [MODERN-TOOLS] Modern tools setup complete!"
