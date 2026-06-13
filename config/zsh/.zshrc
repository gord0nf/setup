export ZSH_CONFIG=${0:A:h}
export PROFILE="$ZSH_CONFIG/.zshrc"
export SOFTWARE="$(realpath "$ZSH_CONFIG/../../")" # @gord0nf/software specific

command_exists() {
  command -v "$1" &>/dev/null
}

# env vars ----------------------------------------------------------------------------------------

if [[ -f "$HOME/.env" ]]; then
  set -a
  source "$HOME/.env"
  set +a
fi

# zinit -------------------------------------------------------------------------------------------

# installation
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions

# zsh settings ------------------------------------------------------------------------------------

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

bindkey -e # emacs
setopt autocd # navigation
autoload -U compinit; compinit # autocomplete

# fzf ---------------------------------------------------------------------------------------------

if command_exists fzf; then
  source <(fzf --zsh)
fi

# oh-my-posh --------------------------------------------------------------------------------------

if command_exists oh-my-posh; then
  conf="$SOFTWARE/config/ohmyposh/${OMP_THEME:-half-life}.omp.json"
  [[ -f "$conf" ]] && eval "$(oh-my-posh init zsh --config "$conf")"
fi

# prettier ----------------------------------------------------------------------------------------

PRETTIERD_DEFAULT_CONFIG="$SOFTWARE/config/nodejs/prettierrc.json"

# aliases -----------------------------------------------------------------------------------------

# Basic cmd line utils
alias -g ll='ls -alh --color=auto'
alias -g la='ls -A --color=auto'
alias -g l='ll -CF'
alias -g ls='ls --color=auto'

# Pretty print PATH
path() { echo "${PATH//:/$'\n'}"; }

# Git shortcuts
alias -g gl='git lg'
alias -g gbl='branch -a'
alias -g gs='git status'
alias -g ga='git add'
alias -g gc='git commit'
alias -g gagc='git add . && git commit'
alias -g gps='git push'
alias -g gpl='git pull'
alias -g grb='git rebase'
alias -g grc='git rebase --continue'
alias -g gd='git diff'
alias -g gco='git checkout'

# Common software shortcuts
alias -g nv='nvim'
alias -g py='python'
alias -g ps='ps aux'
alias -g top='htop'
alias -g server='python -m http.server 8000'
alias -g uploadserver='python -m uploadserver 8000'
alias -g ports='netstat -tuln'
