export ZSH_CONFIG=${0:A:h}
export PROFILE="$ZSH_CONFIG/.zshrc"
export SOFTWARE="$(realpath "$ZSH_CONFIG/../../")" # @gord0nf/software specific

# zsh settings ------------------------------------------------------------------------------------

# history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY

# Configure the push directory stack (most people don't need this)
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Emacs keybindings
bindkey -e
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward

# Move to directories without cd
setopt autocd

# Initialize completion
autoload -U compinit; compinit

# env vars ----------------------------------------------------------------------------------------

if [[ -f "$HOME/.env" ]]; then
  set -a
  source "$HOME/.env"
  set +a
fi

# prettier ----------------------------------------------------------------------------------------

PRETTIERD_DEFAULT_CONFIG="$SOFTWARE/config/nodejs/prettierrc.json"

# aliases -----------------------------------------------------------------------------------------

# Basic cmd line utils
alias -g ll='ls -alh --color=auto'
alias -g la='ls -A --color=auto'
alias -g l='ls -CF --color=auto'
alias -g ls='ls --color=auto'
alias -g ..='cd ..'
alias -g ...='cd ../..'
alias -g ....='cd ../../..'
alias -g grep='grep --color=auto'
alias -g fgrep='fgrep --color=auto'
alias -g egrep='egrep --color=auto'

# File operations
alias -g rm="rm -i"
alias -g mv="mv -i"
alias -g cp="cp -i"
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
alias -g myip='curl -s ifconfig.me && echo'
