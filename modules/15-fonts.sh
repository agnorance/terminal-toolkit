#!/bin/bash
# Fonts Module
# Installs Nerd Fonts system-wide and sets defaults

set -e

echo "🔤 [FONTS] Starting fonts installation..."

# System-wide fonts directory
FONTS_DIR="/usr/local/share/fonts/nerd-fonts"

# Install JetBrainsMono Nerd Font
echo "📦 Installing JetBrainsMono Nerd Font (system-wide)..."

FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
FONT_NAME="JetBrainsMono"
TEMP_DIR=$(mktemp -d)

if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "✅ JetBrainsMono Nerd Font already installed"
else
    echo "⬇️  Downloading JetBrainsMono Nerd Font..."

    # Install unzip if not available
    if ! command -v unzip &> /dev/null; then
        echo "📦 Installing unzip..."
        sudo apt-get update -qq
        sudo apt-get install -y unzip
    fi

    # Download the font
    if curl -L -o "$TEMP_DIR/$FONT_NAME.zip" "$FONT_URL"; then
        echo "📂 Extracting fonts..."

        # Extract
        unzip -q "$TEMP_DIR/$FONT_NAME.zip" -d "$TEMP_DIR/$FONT_NAME"

        # Create system fonts directory
        sudo mkdir -p "$FONTS_DIR"

        # Copy TTF and OTF files to system fonts directory
        echo "📥 Installing to $FONTS_DIR..."
        sudo find "$TEMP_DIR/$FONT_NAME" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONTS_DIR/" \;

        # Cleanup temp files
        rm -rf "$TEMP_DIR"

        echo "✅ JetBrainsMono Nerd Font installed successfully"
    else
        echo "⚠️  Failed to download JetBrainsMono Nerd Font"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

# Set JetBrainsMono as default monospace font system-wide
echo "⚙️  Setting JetBrainsMono as default monospace font..."

FONTCONFIG_DIR="/etc/fonts/local.conf.d"
FONTCONFIG_FILE="$FONTCONFIG_DIR/01-jetbrainsmono-default.conf"

sudo mkdir -p "$FONTCONFIG_DIR"

# Create fontconfig configuration
sudo tee "$FONTCONFIG_FILE" > /dev/null << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Set JetBrainsMono Nerd Font as default monospace font -->
  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrainsMono Nerd Font Mono</family>
      <family>JetBrainsMono Nerd Font</family>
    </prefer>
  </alias>

  <!-- Fallback if JetBrainsMono is requested but not found -->
  <alias>
    <family>JetBrainsMono Nerd Font</family>
    <default>
      <family>monospace</family>
    </default>
  </alias>
</fontconfig>
EOF

# Update font cache system-wide
echo "🔄 Updating font cache..."
sudo fc-cache -f -v "$FONTS_DIR" > /dev/null 2>&1

echo "✅ [FONTS] Fonts installation complete!"
echo ""
echo "💡 JetBrainsMono Nerd Font is now:"
echo "   ✓ Installed system-wide in $FONTS_DIR"
echo "   ✓ Set as default monospace font"
echo "   ✓ Available to all users and applications"
echo ""
echo "📝 To apply in your terminal:"
echo "   - Most terminals will auto-detect the new default"
echo "   - Or manually set to 'JetBrainsMono Nerd Font Mono'"
echo "   - Recommended size: 10-12pt"
