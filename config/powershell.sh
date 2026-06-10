#!/bin/bash

THING=powershell
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/pwsh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

os=$(get_os)
[[ "$os" == 'windows' ]] || fatal "powershell is for windows (os=$os)"

### actual config logic is the same as Powershell Core
. "$(dirname "${BASH_SOURCE[0]}")/pwsh.sh"

# install fonts
log 'installing fonts'
powershell "$CONFIG/../fonts/Install-Fonts.ps1"
