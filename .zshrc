# What should be on your PATH?
PATH="/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/bin:/sbin"  # default unix bins

# Path to your oh-my-zsh installation.
export ZSH="/Users/cruksznis/.oh-my-zsh"

# Set name of the theme to load
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="spaceship"

# Theme options
SPACESHIP_KUBECONTEXT_SHOW="false"
SPACESHIP_GIT_STATUS_SHOW="false"
SPACESHIP_GIT_BRANCH_PREFIX=""
SPACESHIP_PACKAGE_SHOW="false"
# SPACESHIP_DOCKER_SHOW="false"
# SPACESHIP_NODE_SYMBOL=""
# SPACESHIP_PROMPT_PREFIXES_SHOW="false"
# SPACESHIP_PYENV_SYMBOL=""
# SPACESHIP_RUBY_SYMBOL=""
# SPACESHIP_VENV_SYMBOL=""

# Which plugins would you like to load?
plugins=(
  brew
  common-aliases
  fzf-zsh
  git
  jsontools
  node
  npm
  python
  sublime
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh


# User configuration

# Set brew casks to be in the home Applications dir
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Load our dotfiles
#   ~/.extra can be used for settings you don’t want to commit,
#   Use it to configure your PATH, thus it being first in line.
for file in ~/.{extra,aliases,functions}; do
    [ -r "$file" ] && source "$file"
done
unset file

# based heavily on https://elijahmanor.com/uses/

# Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
prompt spaceship

# direnv
eval "$(direnv hook zsh)"
