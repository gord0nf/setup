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

# extra configuration -----------------------------------------------------------------------------

# theme
rm "$CONFIG/theme.ini" -f &>/dev/null
if [[ -v ymlconf_config_foot_theme ]]; then
  if [[ -f "$CONFIG/themes/$ymlconf_config_foot_theme.ini" ]]; then
    log "applying theme '$ymlconf_config_foot_theme'"
    ln -s "$CONFIG/themes/$ymlconf_config_foot_theme.ini" "$CONFIG/theme.ini"
  else
    warn "invalid theme '$ymlconf_config_foot_theme'"
  fi
else
  touch "$CONFIG/theme.ini" # blank file so include directive in foot.ini doesn't fail
fi

# font
if [[ -v FONT || -v FONT_SIZE ]]; then
  font=${FONT:-monospace}
  size=${FONT_SIZE:+:size=$FONT_SIZE}
  log "applying font $font$size"
  echo "font=$font:style=Regular$size
  font-bold=$font:style=Bold$size
  font-italic=$font:style=Italic$size" >"$CONFIG/font.ini"
else
  touch "$CONFIG/font.ini" # blank file so include directive in foot.ini doesn't fail
fi
