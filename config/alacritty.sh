#!/bin/bash

FORCE="${FORCE:-false}"
THING=alacritty
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists nvim && fatal 'not installed'

default_dirs=(
  "${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"
  "${APPDATA:+$APPDATA/alacritty}"
)

# create link from default nvim dir(s) to config
for dir in "${default_dirs[@]}"; do
  if [[ ! -z "$dir" && -d "$(dirname "$dir")" ]]; then
    log "creating directory link from '$dir' to config"
    make_directory_link "$CONFIG" "$dir"
  fi
done

rm "$CONFIG/theme.toml" -f &>/dev/null
if [[ -v ymlconf_config_alacritty_theme ]]; then
  ln -s "$CONFIG/themes/$ymlconf_config_alacritty_theme.toml" "$CONFIG/theme.toml"
else
  touch "$CONFIG/theme.toml" # blank file so include doesn't fail
fi
