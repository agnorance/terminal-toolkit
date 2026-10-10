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

# SSH-login reminders: prints any ~/.reminders/*.md on new SSH sessions.
# Only on interactive SSH shells, and only once per login (skips subshells/tmux panes).
if [[ -n "$SSH_CONNECTION" && -o interactive && -z "$REMINDERS_SHOWN" ]]; then
    setopt local_options null_glob
    reminder_files=(~/.reminders/*.md)
    if (( ${#reminder_files} > 0 )); then
        print -P "%F{yellow}── pending reminders (~/.reminders) ──%f"
        for f in $reminder_files; do
            print -P "%F{cyan}• ${f:t:r}%f"
            sed -n '1,8p' "$f" | sed 's/^/    /'
            print
        done
        print -P "%F{yellow}──────────────────────────────────────%f"
    fi
    export REMINDERS_SHOWN=1
fi

