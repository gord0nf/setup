export ZSH_CONFIG=${0:A:h}
export SOFTWARE="$(realpath "$ZSH_CONFIG/../../")" # @gord0nf/software specific

# env vars ----------------------------------------------------------------------------------------

if [[ -f "$HOME/.env" ]]; then
  set -a
  source "$HOME/.env"
  set +a
fi

# oh-my-zsh configuration -------------------------------------------------------------------------

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#663399,standout"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

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
