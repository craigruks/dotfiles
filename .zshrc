# zmodload zsh/zprof

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add Nix system profile to PATH (for nix-darwin packages)
# This must be done early so Nix-installed tools are available
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# Add system profile bin directory to PATH (/run/current-system is the resolved
# current nix-darwin generation, so this alone covers all nix-installed tools).
if [ -d '/run/current-system/sw/bin' ]; then
  export PATH="/run/current-system/sw/bin:$PATH"
fi

# Add in zsh plugins with lazy loading and blockf for completion plugins
zinit wait lucid blockf for \
    zsh-users/zsh-completions

zinit wait lucid for \
    zsh-users/zsh-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    Aloxaf/fzf-tab

# Add in snippets with wait
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins
zinit wait lucid for \
    OMZL::git.zsh \
    OMZP::git \
    OMZP::command-not-found

# Optimize completion loading with caching
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -C
else
  compinit
fi


# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=1000000          # load full history into memory (file ~68k+ entries)
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE         # never trim the file on save
setopt appendhistory
setopt sharehistory
setopt extended_history
setopt hist_fcntl_lock
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Lazy load fzf history search
zinit wait lucid for joshskidmore/zsh-fzf-history-search

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'

# Aliases
alias finder='open'
alias incognito='fc -p'
# Modern CLI replacements - guarded so the shell still works before the nix
# rebuild installs them (same pattern as mise/zoxide below).
if command -v eza >/dev/null 2>&1; then
  # Mute eza's rainbow: flatten the permission/owner/group/date/size fields to
  # the default foreground, keeping only filename + dir type colors and icons.
  # Tweak any field to re-add accent (e.g. da=36 → cyan dates). Keys: `man eza_colors`.
  export EZA_COLORS="ur=0:uw=0:ux=0:ue=0:gr=0:gw=0:gx=0:tr=0:tw=0:tx=0:su=0:sf=0:xa=0:uu=0:un=0:gu=0:gn=0:da=0:sn=0:sb=0:nb=0:nk=0:nm=0:ng=0:nt=0:df=0:ds=0"
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons'
else
  alias ls='ls --color'
  alias ll='ls -la --color'
fi
command -v bat >/dev/null 2>&1 && alias cat='bat'
alias vim='nvim'
alias rrm='rm -rf'
# clip: copy a file's contents (or piped stdin) to the clipboard.
#   clip file.txt   |   cmd | clip
clip() { if [ $# -eq 0 ]; then pbcopy; else pbcopy < "$1"; fi }

# Homebrew - must come before mise so brew-installed binaries are on PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# 1Password service-account token - "secret zero", the MACHINE default. It's what
# lets fnox / op / varlock resolve every other secret headlessly (no GUI prompt,
# works on the remote box). Can't live in 1Password itself (chicken-and-egg), so
# it sits in the macOS login keychain - never a plaintext file, never in git.
#   Seed once:  security add-generic-password -s osx-cli-sa -a "$USER" -w
#   (paste the token at the hidden prompt; -w with no value keeps it off argv)
# MUST precede `mise activate`: this sets the machine-wide default, then a
# per-project .mise.local.toml overrides OP_SERVICE_ACCOUNT_TOKEN with a narrower,
# repo-scoped token (e.g. fin-deploy) when you cd into that repo - so a project
# shell carries ONLY its own token, never momentarily the broader cli one.
if command -v security >/dev/null 2>&1; then
  OP_SERVICE_ACCOUNT_TOKEN="$(security find-generic-password -s osx-cli-sa -a "$USER" -w 2>/dev/null)" \
    && export OP_SERVICE_ACCOUNT_TOKEN
fi

# Mise - initialize if available (installed via Nix)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Zoxide - initialize if available (installed via Nix)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd z zsh)"
fi

# fnox - ambient machine secrets in every shell (see .config/fnox/config.toml).
# Commented until an ambient secret is actually declared, per "only what I use":
# the token export above already lets per-project `fnox`/`varlock` work headlessly.
# Uncomment once .config/fnox/config.toml has entries under [secrets]:
# command -v fnox >/dev/null 2>&1 && [ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ] && eval "$(fnox activate zsh)"

# Sesh sessions
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -z -c -d | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}
zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

# Editor
export EDITOR=nvim
export VISUAL=nvim

# 1Password SSH agent (the service-account token is set earlier, before mise)
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Personal scripts win: prepend ~/.local/bin last, after nix + brew.
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Starship prompt - stock config (drop a ~/.config/starship.toml to customize).
# Init goes last, per Starship's recommendation.
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# zprof
