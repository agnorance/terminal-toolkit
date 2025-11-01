# Terminal Toolkit

A modular, portable terminal setup for Debian/Ubuntu/Kali systems (including WSL). Quickly bootstrap a new machine with your favorite tools and configurations.

## Features

- **Profile-Based**: Auto-detects OS (Kali/Debian) and adjusts installation
- **Modular Design**: Install only what you need
- **Portable**: Keep everything in git - clone and go
- **Smart Restore**: Auto-detects existing configs on new machines
- **Modern Tools**: eza, zoxide, fzf, ripgrep, bat, and more
- **Security Tools**: impacket, kerbrute, NetExec
- **Beautiful Shell**: zsh + oh-my-zsh + Starship prompt
- **Nerd Fonts**: JetBrainsMono with icons and symbols

## Profiles

The setup automatically detects your OS and uses the appropriate profile:

- **kali**: Minimal install, skips pre-installed tools (Kali Linux)
- **debian**: Full installation (Debian/Ubuntu)
- **minimal**: Only shell + dotfiles, no heavy tools

You can manually override: `./setup.sh --profile=debian`

## Quick Start

### First Time Setup

```bash
# Clone this repo
git clone <your-repo-url> terminal-toolkit
cd terminal-toolkit

# Run setup (installs everything)
chmod +x setup.sh
./setup.sh

# Backup your customized configs
chmod +x scripts/*.sh
./scripts/backup.sh

# Commit and push
git add dotfiles/
git commit -m "Add my dotfiles"
git push
```

### New Machine Setup

```bash
# Clone your repo
git clone <your-repo-url> terminal-toolkit
cd terminal-toolkit

# Run setup (auto-restores your configs!)
chmod +x setup.sh
./setup.sh

# That's it! Your machine is ready
exec zsh
```

## Structure

```
terminal-toolkit/
├── setup.sh              # Main orchestrator script
├── modules/              # Modular installation scripts
│   ├── 00-system.sh     # System updates + essential packages
│   ├── 10-shell.sh      # zsh + oh-my-zsh + plugins
│   ├── 15-fonts.sh      # Nerd Fonts (JetBrainsMono)
│   ├── 20-starship.sh   # Starship prompt
│   ├── 30-modern-tools.sh # eza, zoxide, fzf, ripgrep, bat, etc.
│   └── 90-security-tools.sh # impacket, kerbrute, nxc, seclists
├── scripts/              # Utility scripts
│   ├── backup.sh        # Backup dotfiles to repo
│   └── restore.sh       # Restore dotfiles from repo
├── dotfiles/             # Your backed up configs
│   ├── .zshrc
│   ├── .gitconfig
│   ├── starship.toml
│   └── ...
└── README.md             # This file
```

## Available Modules

### 00-system.sh (Required)
- System updates and upgrades
- Essential build tools
- Core utilities: git, curl, wget, vim, tmux
- System tools: btop, ncdu, duf, procs
- Networking: net-tools, netcat, tcpdump
- Development: python3, pip3
- Utilities: jq, tree, tldr, httpie

### 10-shell.sh
- zsh shell
- oh-my-zsh framework
- zsh-autosuggestions plugin
- zsh-syntax-highlighting plugin
- Sets zsh as default shell

### 15-fonts.sh
- JetBrainsMono Nerd Font (system-wide)
- Installed to `/usr/local/share/fonts/nerd-fonts`
- Set as default monospace font
- Includes icons and symbols for better terminal UI

### 20-starship.sh
- Starship prompt (cross-shell)
- Tokyo Night preset
- Handles config from repo if available

### 30-modern-tools.sh
- **eza**: Modern ls replacement
- **zoxide**: Smarter cd (learns your patterns)
- **fzf**: Fuzzy file finder
- **ripgrep**: Fast grep alternative
- **fd-find**: Better find command
- **bat**: Cat with syntax highlighting

### 90-security-tools.sh
- **impacket**: Network protocol tools
- **kerbrute**: Kerberos user enumeration
- **NetExec (nxc)**: Network execution tool

## Usage

### Setup Script

```bash
./setup.sh
```

Interactive prompts will let you:
1. Restore existing dotfiles (if found in repo)
2. Select which modules to install
3. Choose to regenerate .zshrc or keep existing

### Backup Script

```bash
./scripts/backup.sh
```

Backs up these files to `dotfiles/`:
- `.zshrc`
- `.gitconfig`
- `.vimrc`
- `starship.toml`
- `.tmux.conf` (if exists)

### Restore Script

```bash
./scripts/restore.sh
```

Restores all backed up dotfiles from repo to your home directory.

## Configured Aliases

After setup, these aliases will be available:

- `ls` → `eza --icons` - Better directory listing
- `ll` → `eza -la --icons` - Detailed listing
- `lt` → `eza --tree --icons` - Tree view
- `cat` → `batcat` - Syntax highlighted cat
- `fd` → `fdfind` - Better file finder
- `cd` → `z` - Smart cd with zoxide

## Keyboard Shortcuts

- `Ctrl+R` - fzf fuzzy history search
- `Ctrl+T` - fzf file search
- `Ctrl+O` - Accept autosuggestion

## Custom Functions

- `mkcd <dir>` - Create directory and cd into it

## Proxy Support

The scripts automatically detect and configure proxy settings from `/etc/profile.d/proxy.sh` if available.

## WSL vs Native Linux

The setup automatically detects if running in WSL or native Linux and adjusts accordingly.

## Troubleshooting

### Scripts not executable?
```bash
chmod +x setup.sh scripts/*.sh modules/*.sh
```

### Shell not changed?
```bash
exec zsh
```

### Starship not loading?
Make sure `~/.config/starship.toml` exists and your `.zshrc` has:
```bash
eval "$(starship init zsh)"
```

### Security tools installation taking long?
NetExec (nxc) requires Rust compilation which can take several minutes. This is normal.

## Customization

### Adding New Modules

1. Create a new script in `modules/` (e.g., `50-mytools.sh`)
2. Follow the pattern:
   ```bash
   #!/bin/bash
   set -e
   echo "🔧 [MYTOOLS] Starting..."
   # Your installation commands
   echo "✅ [MYTOOLS] Complete!"
   ```
3. Update `setup.sh` to include it in the module list

### Adding New Dotfiles

Edit `scripts/backup.sh` and `scripts/restore.sh` to include additional files.

## License

MIT - Do whatever you want with it!

## Credits

Built for rapid deployment and consistency across development environments.
