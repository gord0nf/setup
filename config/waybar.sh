#!/bin/bash

FORCE="${FORCE:-false}"
THING=waybar
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists waybar && fatal 'not installed'

# create link from default dir(s) to config (if configured)
dir="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
if [[ -v ymlconf_config_waybar_config ]]; then
  [[ -d "$CONFIG/$ymlconf_config_waybar_config" ]] ||
    warn "invalid config '$ymlconf_config_waybar_config'"
  log "creating directory link from '$dir' to config"
  make_directory_link "$CONFIG/$ymlconf_config_waybar_config" "$dir"
fi

# for compatibility with sway (note: this could be overridden if sway is configured after)
[[ -v ymlconf_config_sway_bar ]] || {
  log 'setting waybar as default sway bar'
  set_global_env SWAYBAR waybar
}
