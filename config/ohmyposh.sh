#!/bin/bash

FORCE="${FORCE:-false}"
THING=ohmyposh
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists oh-my-posh && fatal 'not installed'

[[ -v ymlconf_config_ohmyposh_theme ]] &&
  set_global_env OMP_THEME "$ymlconf_config_ohmyposh_theme" ||
  set_global_env OMP_THEME -unset
