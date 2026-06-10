#!/bin/bash

FORCE="${FORCE:-false}"
THING=sway
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

[[ $(get_os) != 'windows' ]] || fatal "sway is for linux (os=windows)"
! $FORCE && ! command_exists sway && fatal 'not installed'

# dir link for config
[[ $EUID -eq 0 ]] && sway_dir=/etc/sway || sway_dir=$HOME/.config/sway
log "creating directory link from '$sway_dir' to config"
make_directory_link "$CONFIG" "$sway_dir"

# extra configuration with env vars ---------------------------------------------------------------

log 'applying yaml configuration stuff'

# startBehavior should be login|prompt|manual
[[ -v ymlconf_config_sway_startBehavior ]] &&
  set_global_env SWAY_START "$ymlconf_config_sway_startBehavior" ||
  set_global_env SWAY_START -unset
