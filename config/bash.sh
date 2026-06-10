#!/bin/bash

FORCE="${FORCE:-false}"
THING=bash
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists bash && fatal 'not installed'

# set ~/.bashrc to source $config_dir/bashrc
log 'making sure ~/.bashrc sources config'
sed -i '/#@gord0nf\/software/d' ~/.bashrc &>/dev/null # clean all lines with special comment
echo ". '$CONFIG/bashrc' #@gord0nf/software" >>~/.bashrc

# set ~/.profile to source $config_dir/bash_profile
log 'making sure ~/.profile sources config'
sed -i '/#@gord0nf\/software/d' ~/.profile &>/dev/null # clean all lines with special comment
echo ". '$CONFIG/bash_profile' #@gord0nf/software" >>~/.profile

# install fonts
log 'installing fonts'
bash "$CONFIG/../fonts/install_fonts.sh"
