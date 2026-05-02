#!/bin/bash

THING=powershell
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

os=$(get_os)
[[ "$os" == 'windows' ]] || fatal "powershell is for windows (os=$os)"
command_exists powershell || fatal " ur on windows and don't have powershell... that ain't right"

log 'already installed'
