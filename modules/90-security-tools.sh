#!/bin/bash
# Security Tools Module
# Installs penetration testing and security tools

set -e

echo "🔐 [SECURITY] Starting security tools setup..."

# Skip on Kali (already has these tools)
if [ "$PROFILE" = "kali" ]; then
    echo "   Kali detected - security tools likely pre-installed"
    echo "   Verifying installation..."

    # Just verify key tools exist
    TOOLS=("impacket:python3 -c 'import impacket'" "kerbrute:command -v kerbrute" "nxc:command -v nxc")

    ALL_PRESENT=true
    for tool_check in "${TOOLS[@]}"; do
        tool_name="${tool_check%%:*}"
        check_cmd="${tool_check#*:}"

        if eval "$check_cmd" &> /dev/null; then
            echo "   ✓ $tool_name"
        else
            echo "   ✗ $tool_name (not found)"
            ALL_PRESENT=false
        fi
    done

    if [ "$ALL_PRESENT" = true ]; then
        echo "✅ [SECURITY] All security tools verified!"
        exit 0
    else
        echo ""
        echo "⚠️  Some tools missing. Install them manually or run:"
        echo "   ./setup.sh --profile=debian"
        exit 0
    fi
fi

# Skip on minimal profile
if [ "$PROFILE" = "minimal" ]; then
    echo "   Minimal profile - skipping security tools"
    echo "✅ [SECURITY] Skipped (minimal profile)"
    exit 0
fi

# Full installation for Debian/Ubuntu
echo "   Installing security tools for Debian/Ubuntu..."

# Install impacket
echo "📦 Installing impacket..."
if python3 -c "import impacket" 2>/dev/null; then
    echo "✅ impacket already installed"
else
    # Use pipx for externally-managed Python environments
    if ! command -v pipx &> /dev/null; then
        sudo apt install -y pipx
        pipx ensurepath > /dev/null 2>&1
        export PATH="$HOME/.local/bin:$PATH"
    fi
    pipx install impacket
    echo "✅ impacket installed"
fi

# Install kerbrute
echo "🎯 Installing kerbrute..."
if command -v kerbrute &> /dev/null; then
    echo "✅ kerbrute already installed"
else
    KERBRUTE_VERSION="v1.0.3"
    wget -q "https://github.com/ropnop/kerbrute/releases/download/${KERBRUTE_VERSION}/kerbrute_linux_amd64" -O /tmp/kerbrute
    sudo mv /tmp/kerbrute /usr/local/bin/kerbrute
    sudo chmod +x /usr/local/bin/kerbrute
    echo "✅ kerbrute installed"
fi

# Install NetExec (nxc)
echo "🌐 Installing NetExec (nxc)..."
if command -v nxc &> /dev/null; then
    echo "✅ nxc already installed ($(nxc --version 2>/dev/null || echo 'version unknown'))"
else
    # Check if pipx is installed
    if ! command -v pipx &> /dev/null; then
        echo "   Installing pipx..."
        sudo apt install -y pipx
        pipx ensurepath > /dev/null 2>&1
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Check if rust is installed (required for building nxc)
    if ! command -v cargo &> /dev/null; then
        echo "   Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    echo "   Installing nxc via pipx (this may take a few minutes)..."
    pipx install git+https://github.com/Pennyw0rth/NetExec

    echo "✅ nxc installed"
    echo "   Note: You may need to restart your shell or run: source ~/.zshrc"
fi

echo "✅ [SECURITY] Security tools setup complete!"
echo ""
echo "📝 Installed tools:"
echo "   • impacket    - Network protocol manipulation"
echo "   • kerbrute    - Kerberos user enumeration"
echo "   • nxc         - Network execution tool (NetExec)"
echo ""
echo "💡 Note: Restart your shell or run 'exec zsh' to ensure pipx tools are in PATH"
