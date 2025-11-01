#!/bin/bash
# System Setup Module
# Handles WSL detection, proxy config, system updates, and essential packages

set -e

echo "📦 [SYSTEM] Starting system setup..."

# WSL Detection
export IS_WSL=false
if grep -qi "microsoft" /proc/version 2>/dev/null; then
    IS_WSL=true
    echo "🪟 Running in WSL"
else
    echo "🐧 Running on native Linux"
fi

# Proxy Configuration
echo "🌐 Checking proxy configuration..."
if [ -f /etc/profile.d/proxy.sh ]; then
    echo "   Loading proxy settings from /etc/profile.d/proxy.sh..."
    source /etc/profile.d/proxy.sh 2>/dev/null || true

    if [ -n "$http_proxy" ] && [ "$http_proxy" != '$proxy_value' ]; then
        export HTTP_PROXY="$http_proxy"
        export HTTPS_PROXY="$https_proxy"
        echo "✅ Proxy configured: $http_proxy"
    else
        echo "⚠️  Proxy file exists but proxy not set. Continuing without proxy..."
    fi
else
    echo "   No proxy configuration found. Continuing without proxy..."
fi

# System Update
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Profile-based installation
if [ "$PROFILE" = "minimal" ]; then
    echo "📦 Installing minimal essentials..."
    sudo apt install -y \
        git \
        curl \
        wget \
        vim
    echo "✅ [SYSTEM] Minimal system setup complete!"
    exit 0
fi

# Essential Tools Installation (Kali has many pre-installed)
echo "🔧 Installing essential tools..."

if [ "$PROFILE" = "kali" ]; then
    echo "   Kali detected - checking for missing tools only..."
    # On Kali, many tools are pre-installed. Only install if missing.
    TOOLS_TO_CHECK=(
        "git" "curl" "wget" "build-essential" "unzip"
        "tmux" "vim" "neovim" "ncdu" "jq" "tree"
    )

    MISSING_TOOLS=()
    for tool in "${TOOLS_TO_CHECK[@]}"; do
        if ! dpkg -l | grep -q "^ii  $tool"; then
            MISSING_TOOLS+=("$tool")
        fi
    done

    if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
        echo "   Installing missing tools: ${MISSING_TOOLS[*]}"
        sudo apt install -y "${MISSING_TOOLS[@]}"
    else
        echo "   ✅ All essential tools already installed"
    fi
else
    # Full installation for Debian/Ubuntu
    sudo apt install -y \
        git \
        curl \
        wget \
        build-essential \
        unzip \
        btop \
        jq \
        tree \
        python-dev-is-python3 \
        python3-dev \
        python3-pip \
        tmux \
        vim \
        neovim \
        ncdu \
        net-tools \
        netcat-openbsd \
        tcpdump \
        httpie \
        xclip \
        wl-clipboard
fi

# Install duf (better df) - check if available first
if [ "$PROFILE" != "kali" ]; then
    echo "💾 Installing duf..."
    if command -v duf &> /dev/null; then
        echo "✅ duf already installed"
    else
        if apt-cache show duf &> /dev/null 2>&1; then
            sudo apt install -y duf
        else
            echo "   Installing duf from GitHub releases..."
            DUF_VERSION=$(curl -s https://api.github.com/repos/muesli/duf/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
            wget -q "https://github.com/muesli/duf/releases/download/${DUF_VERSION}/duf_${DUF_VERSION#v}_linux_amd64.deb" -O /tmp/duf.deb
            sudo dpkg -i /tmp/duf.deb
            rm /tmp/duf.deb
        fi
        echo "✅ duf installed"
    fi
fi

# Install procs (better ps) - check if available first
if [ "$PROFILE" != "kali" ]; then
    echo "⚙️  Installing procs..."
    if command -v procs &> /dev/null; then
        echo "✅ procs already installed"
    else
        if apt-cache show procs &> /dev/null 2>&1; then
            sudo apt install -y procs
        else
            echo "   Installing procs from GitHub releases..."
            PROCS_VERSION=$(curl -s https://api.github.com/repos/dalance/procs/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
            wget -q "https://github.com/dalance/procs/releases/download/${PROCS_VERSION}/procs-${PROCS_VERSION}-x86_64-linux.zip" -O /tmp/procs.zip
            unzip -q /tmp/procs.zip -d /tmp/
            sudo mv /tmp/procs /usr/local/bin/
            sudo chmod +x /usr/local/bin/procs
            rm /tmp/procs.zip
        fi
        echo "✅ procs installed"
    fi
fi

echo "✅ [SYSTEM] System setup complete!"
