#!/bin/bash

force=false
if [[ "$1" == '--force' ]]; then
  force=true
fi

THING=pwsh
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/pwsh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $force && ! command_exists pwsh && fatal 'not installed'

# run setup script (modules, etc)
log 'running setup script'
pwsh -ExecutionPolicy RemoteSigned -NoProfile "$CONFIG/Setup-Pwsh.ps1"

# link profile
profile=$(convert_path_if_needed --unix "$(eval "pwsh -NoProfile -Command 'Write-Host \$PROFILE'")")
if ! [[ -f "$profile" ]]; then
  warn "PS profile file doesn't exist, so creating: $profile"
  mkdir -p "$(dirname "$profile")" && touch "$profile"
fi
log "making sure '$profile' sources config"
sed -i '/#@gord0nf\/software/d' "$profile" &>/dev/null # clean all lines with special comment
echo ". '$(convert_path_if_needed --windows "$CONFIG/PowerShell_profile.ps1")' #@gord0nf/software" >>"$profile"
