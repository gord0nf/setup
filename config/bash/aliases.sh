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
