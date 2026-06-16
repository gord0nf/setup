#!/bin/bash

FORCE="${FORCE:-false}"
THING=fuzzel
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists fuzzel && fatal 'not installed'

dir="${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel"

# create link from default nvim dir(s) to config
log "creating directory link from '$dir' to config"
make_directory_link "$CONFIG" "$dir"

# for compatibility with sway (note: this could be overridden if sway is configured after)
[[ -v ymlconf_config_sway_menu ]] || {
  log 'setting fuzzel as default sway menu'
  set_global_env SWAYMENU fuzzel
}
