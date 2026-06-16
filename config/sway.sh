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

# env var config ----------------------------------------------------------------------------------

[[ -v ymlconf_config_sway_menu ]] &&
  set_global_env SWAYMENU "$ymlconf_config_sway_menu" ||
  set_global_env SWAYMENU -unset

[[ -v ymlconf_config_sway_bar ]] &&
  set_global_env SWAYBAR "$ymlconf_config_sway_bar" ||
  set_global_env SWAYBAR -unset

# start behavior configuration --------------------------------------------------------------------
# ymlconf_config_sway_startBehavior should be login|prompt|manual

for p in .profile .bash_profile .zprofile; do
  profile="$HOME/$p"
  log "apply start behavior to $profile"
  sed -i '/#@gord0nf\/software/d' "$profile" &>/dev/null # clean all lines with special comment
  case "$ymlconf_config_sway_startBehavior" in
  login | prompt)
    echo "SWAY_START=$ymlconf_config_sway_startBehavior bash '$CONFIG/scripts/profile.sh' #@gord0nf/software" \
      >>"$profile"
    ;;
  esac
done
