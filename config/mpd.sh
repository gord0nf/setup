#!/bin/bash

FORCE="${FORCE:-false}"
THING=mpd
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists mpd && fatal 'not installed'

dir=${XDG_CONFIG_HOME:-$HOME/.config}/mpd
log "creating directory link from '$dir' to config"
make_directory_link "$CONFIG" "$dir"
