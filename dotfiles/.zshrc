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

# Starship prompt (best of both worlds!)
eval "$(starship init zsh)"

# Custom functions
mkcd() { mkdir -p "$1" && cd "$1"; }

