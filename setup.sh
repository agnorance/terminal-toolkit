#!/bin/bash
# Terminal Toolkit - Main Setup Script
# Orchestrates all setup modules

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

# Profile detection and selection
detect_os() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "$ID" == "kali" ]] || [[ "$ID_LIKE" == *"kali"* ]]; then
            echo "kali"
        elif [[ "$ID" == "debian" ]] || [[ "$ID_LIKE" == *"debian"* ]] || [[ "$ID_LIKE" == *"ubuntu"* ]]; then
            echo "debian"
        else
            echo "debian"  # Default fallback
        fi
    else
        echo "debian"  # Default fallback
    fi
}

# Parse command line arguments
PROFILE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --profile=*)
            PROFILE="${1#*=}"
            shift
            ;;
        --profile)
            PROFILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--profile=kali|debian|minimal]"
            exit 1
            ;;
    esac
done

# Auto-detect if not specified
if [ -z "$PROFILE" ]; then
    DETECTED_OS=$(detect_os)
    PROFILE="$DETECTED_OS"
fi

# Export for modules to use
export PROFILE

echo "════════════════════════════════════════════════════════"
echo "  🚀 Terminal Toolkit Setup"
echo "════════════════════════════════════════════════════════"
echo ""
echo "📋 Profile: $PROFILE"
echo ""

# Check if dotfiles exist in repo and offer to restore
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    echo "📂 Existing dotfiles detected in repo!"
    echo ""
    read -p "Would you like to restore them before setup? (y/n) [y]: " restore_choice
    restore_choice=${restore_choice:-y}

    if [[ "$restore_choice" =~ ^[Yy]$ ]]; then
        echo "♻️  Restoring dotfiles..."
        bash "$SCRIPTS_DIR/restore.sh"
    else
        echo "⏭️  Skipping restore, will create new configs..."
    fi
    echo ""
fi

# Module selection
echo "📦 Available modules:"
echo "  [1] System essentials (required)"
echo "  [2] Shell (zsh + oh-my-zsh)"
echo "  [3] Fonts (JetBrainsMono Nerd Font)"
echo "  [4] Starship prompt"
echo "  [5] Modern CLI tools (eza, zoxide, fzf, etc.)"
echo "  [6] Security tools (impacket, kerbrute, nxc, seclists)"
echo ""
read -p "Install all modules? (y/n) [y]: " install_all
install_all=${install_all:-y}

if [[ "$install_all" =~ ^[Yy]$ ]]; then
    MODULES=("00-system.sh" "10-shell.sh" "15-fonts.sh" "20-starship.sh" "30-modern-tools.sh" "90-security-tools.sh")
else
    echo ""
    echo "Select modules to install (e.g., '1 2 3' or 'all'):"
    read -p "Modules: " module_choice

    if [[ "$module_choice" == "all" ]]; then
        MODULES=("00-system.sh" "10-shell.sh" "15-fonts.sh" "20-starship.sh" "30-modern-tools.sh" "90-security-tools.sh")
    else
        MODULES=()
        for num in $module_choice; do
            case $num in
                1) MODULES+=("00-system.sh") ;;
                2) MODULES+=("10-shell.sh") ;;
                3) MODULES+=("15-fonts.sh") ;;
                4) MODULES+=("20-starship.sh") ;;
                5) MODULES+=("30-modern-tools.sh") ;;
                6) MODULES+=("90-security-tools.sh") ;;
                *) echo "⚠️  Unknown module: $num" ;;
            esac
        done
    fi
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "  Starting installation..."
echo "════════════════════════════════════════════════════════"
echo ""

# Run selected modules
for module in "${MODULES[@]}"; do
    if [ -f "$MODULES_DIR/$module" ]; then
        echo ""
        bash "$MODULES_DIR/$module"
        echo ""
    else
        echo "⚠️  Module not found: $module"
    fi
done

# Check if Starship was installed
if command -v starship &> /dev/null; then
    STARSHIP_INSTALLED=true
else
    STARSHIP_INSTALLED=false
fi

# Generate .zshrc if it doesn't exist or if user wants to regenerate
if [ -f "$HOME/.zshrc" ]; then
    echo "⚙️  .zshrc already exists"
    read -p "Regenerate .zshrc? (y/n) [n]: " regenerate
    regenerate=${regenerate:-n}

    if [[ ! "$regenerate" =~ ^[Yy]$ ]]; then
        SKIP_ZSHRC=true
    fi
fi

if [ "$SKIP_ZSHRC" != true ]; then
    echo "⚙️  Generating .zshrc..."

    if [ "$STARSHIP_INSTALLED" = true ]; then
        cat > ~/.zshrc << 'EOF'
# Source proxy script to get proxyon/proxyoff functions and set proxy
if [ -f /etc/profile.d/proxy.sh ]; then
    source /etc/profile.d/proxy.sh 2>/dev/null || true
fi

# Add local bin to PATH (for zoxide and other tools)
export PATH="$HOME/.local/bin:$PATH"

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Disable oh-my-zsh theme (we're using Starship)
ZSH_THEME=""

# Plugins
plugins=(
    git
    docker
    kubectl
    fzf
    sudo
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='vim'

# Aliases
alias ls='eza --icons'
alias ll='eza -la --icons'
alias lt='eza --tree --icons'
alias cat='batcat'
alias fd='fdfind'

# fzf configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# zoxide setup (smarter cd)
eval "$(zoxide init zsh)"
alias cd='z'

# Starship prompt
eval "$(starship init zsh)"

# Custom functions
mkcd() { mkdir -p "$1" && cd "$1"; }

EOF
    else
        cat > ~/.zshrc << 'EOF'
# Source proxy script to get proxyon/proxyoff functions and set proxy
if [ -f /etc/profile.d/proxy.sh ]; then
    source /etc/profile.d/proxy.sh 2>/dev/null || true
fi

# Add local bin to PATH (for zoxide and other tools)
export PATH="$HOME/.local/bin:$PATH"

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# oh-my-zsh theme (using this since Starship isn't available)
ZSH_THEME="agnoster"

# Plugins
plugins=(
    git
    docker
    kubectl
    fzf
    sudo
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='vim'

# Aliases
alias ls='eza --icons'
alias ll='eza -la --icons'
alias lt='eza --tree --icons'
alias cat='batcat'
alias fd='fdfind'

# fzf configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# zoxide setup (smarter cd)
eval "$(zoxide init zsh)"
alias cd='z'

# Custom functions
mkcd() { mkdir -p "$1" && cd "$1"; }

EOF
    fi

    echo "✅ .zshrc generated"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "  ✅ Setup Complete!"
echo "════════════════════════════════════════════════════════"
echo ""
echo "📝 Next steps:"
echo "  1. Close and reopen your terminal (or run: exec zsh)"
echo "  2. Run ./scripts/backup.sh to save your configs to this repo"
echo "  3. Commit and push this repo to preserve your setup"
echo ""
echo "💡 Useful commands:"
echo "  ./scripts/backup.sh  - Backup dotfiles to repo"
echo "  ./scripts/restore.sh - Restore dotfiles from repo"
echo ""
echo "🎯 Configured aliases:"
echo "  ls/ll/lt - Better directory listings with eza"
echo "  cat      - Better cat with batcat"
echo "  cd       - Smarter cd with zoxide"
echo ""
echo "⌨️  Keyboard shortcuts:"
echo "  Ctrl+R   - fzf history search"
echo "  Ctrl+T   - fzf file search"
echo ""
echo "Happy hacking! 🚀"
