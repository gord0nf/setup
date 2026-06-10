export BASH_CONFIG=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
export SOFTWARE="$(realpath "$BASH_CONFIG/../../")" # @gord0nf/software specific

export TERM=xterm-256color
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export LANG="en_US.UTF-8"

command_exists() {
  command -v "$1" &>/dev/null
}

# env vars --------------------------------------------------------------------------------------------

if [[ -f "$HOME/.env" ]]; then
  set -a
  source "$HOME/.env"
  set +a
fi

# oh-my-posh --------------------------------------------------------------------------------------

if command_exists oh-my-posh; then
  theme=${OMP_THEME:-half-life}
  conf="$SOFTWARE/config/ohmyposh/$theme.omp.json"
  [[ -f "$conf" ]] && eval "$(oh-my-posh init bash --config "$conf")"
fi

# prettier ----------------------------------------------------------------------------------------

export PRETTIERD_DEFAULT_CONFIG="$SOFTWARE/config/nodejs/prettierrc.json"

# aliases -----------------------------------------------------------------------------------------

# Basic cmd line utils
alias ll='ls -alh --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# File operations
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias mkdir='mkdir -pv'
alias rmdir='rmdir -v'

# Pretty print PATH
path() { echo "${PATH//:/$'\n'}"; }

# System information shortcuts
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias top='htop'
