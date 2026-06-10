#!/bin/bash

FORCE="${FORCE:-false}"
THING=foot
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists foot && fatal 'not installed'

foot_dir=${XDG_CONFIG_HOME:-$HOME/.config}/foot
log "creating directory link from '$foot_dir' to config"
make_directory_link "$CONFIG" "$foot_dir"
