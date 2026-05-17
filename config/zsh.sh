#!/bin/bash

FORCE="${FORCE:-false}"
THING=zsh
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists zsh && fatal 'not installed'

# set ~/.zshrc to source $config_dir/zshrc.sh
log 'making sure ~/.zshrc sources config'
sed -i '/#@gord0nf\/software/d' "$HOME/.zshrc" &>/dev/null # clean all lines with special comment
echo ". '$CONFIG/zshrc.sh' #@gord0nf/software" >>"$HOME/.zshrc"
