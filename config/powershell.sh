#!/bin/bash

force=false
if [[ "$1" == '--force' ]]; then
  force=true
fi

THING=powershell
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/pwsh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

os=$(get_os)
[[ "$os" == 'windows' ]] || fatal "powershell is for windows (os=$os)"

log 'bootstrapping Windows Powershell'
powershell -ExecutionPolicy RemoteSigned -NoProfile "$CONFIG/setup/Bootstrap-WindowsPowershell.ps1"

# actual config logic is the same as Powershell Core
. "$(dirname "${BASH_SOURCE[0]}")/pwsh.sh"
