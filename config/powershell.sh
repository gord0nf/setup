#!/bin/bash

force=false
if [[ "$1" == '--force' ]]; then
  force=true
fi

THING=powershell
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/powershell"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

os=$(get_os)
[[ "$os" == 'windows' ]] || fatal "powershell is for windows (os=$os)"
command_exists powershell || fatal " ur on windows and don't have powershell... that ain't right"

# run setup script (modules, etc)
log 'running setup script'
powershell -NoProfile -Command 'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force'
powershell -NoProfile "$CONFIG/Setup-Powershell.ps1"

# link profile
profile=$(convert_path_if_needed --unix "$(eval "powershell -NoProfile -Command 'Write-Host \$PROFILE'")")
if ! [[ -f "$profile" ]]; then
  warn "PS profile file doesn't exist, so creating: $profile"
  mkdir -p "$(dirname "$profile")" && touch "$profile"
fi
log "making sure '$profile' sources config"
sed -i '/#@gord0nf\/software/d' "$profile" &>/dev/null # clean all lines with special comment
echo ". '$(convert_path_if_needed --windows "$CONFIG/PowerShell_profile.ps1")' #@gord0nf/software" >>"$profile"
