#!/bin/bash

force=false
if [[ "$1" == '--force' ]]; then
  force=true
fi

# supports being called from config/powershell.sh
[[ "$THING" == powershell ]] || THING=pwsh

CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/pwsh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $force && ! command_exists $THING && fatal 'not installed'

# link config dir
profile=$(eval "$THING -NoProfile -Command 'Write-Host \$PROFILE'")
powershell_dir=$(dirname "$(convert_path_if_needed --unix "$profile")")
log "creating dir link from '$powershell_dir' to config"
make_directory_link "$CONFIG" "$powershell_dir" $force

# bootstrap if Windows Powershell
[[ $THING == powershell ]] && {
  log 'bootstrapping Windows Powershell'
  powershell -ExecutionPolicy RemoteSigned -NoProfile "$CONFIG/setup/Bootstrap-WindowsPowershell.ps1"
}

# run setup script (modules, etc)
log 'running setup script'
$THING -ExecutionPolicy RemoteSigned -NoProfile "$CONFIG/setup/Setup-Powershell.ps1"
