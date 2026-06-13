export ZSH_CONFIG=${0:A:h}
export PROFILE="$ZSH_CONFIG/.zshrc"
export SOFTWARE="$(realpath "$ZSH_CONFIG/../../")" # @gord0nf/software specific

command_exists() {
  command -v "$1" &>/dev/null
}

# history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY

# directory stack
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# keybindings
bindkey -e # emacs
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward

setopt autocd # navigation
autoload -U compinit; compinit # autocomplete

# env vars ----------------------------------------------------------------------------------------

if [[ -f "$HOME/.env" ]]; then
  set -a
  source "$HOME/.env"
  set +a
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
alias -g grep='grep --color=auto'
alias -g fgrep='fgrep --color=auto'
alias -g egrep='egrep --color=auto'

# File operations
alias -g mkdir='mkdir -pv'
alias -g rmdir='rmdir -v'

# Pretty print PATH
path() { echo "${PATH//:/$'\n'}"; }

# Common software shortcuts
alias -g nv='nvim'
alias -g py='python'

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

# System information shortcuts
alias -g df='df -h'
alias -g du='du -h'
alias -g free='free -h'
alias -g ps='ps aux'
alias -g top='htop'

# Other dev utils
alias -g server='python -m http.server 8000'
alias -g uploadserver='python -m uploadserver 8000'
alias -g ports='netstat -tuln'
