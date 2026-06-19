#!/bin/bash

FORCE="${FORCE:-false}"
THING=neovim
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists nvim && fatal 'not installed'

default_nvim_dirs=(
  "$HOME/.config/nvim"
  "$HOME/AppData/Local/nvim"
)

# create link from default nvim dir(s) to config
for nvim_dir in "${default_nvim_dirs[@]}"; do
  if [[ -d "$(dirname "$nvim_dir")" ]]; then
    log "creating directory link from '$nvim_dir' to config"
    make_directory_link "$CONFIG" "$nvim_dir"
  fi
done

# set default prettier
[[ -v PRETTIERD_DEFAULT_CONFIG ]] || set_global_env PRETTIERD_DEFAULT_CONFIG \
  "$CONFIG/.prettierrc"

# extra configuration -----------------------------------------------------------------------------
# by creating a settings.lua file that is imported by neovim config

settings="$CONFIG/lua/settings.lua"
echo "Settings = {}" >"$settings"

[[ "$ymlconf_config_neovim_flash" == true ]] && {
  log 'applying flash'
  echo "Settings.flash = true" >>"$settings"
}
[[ "$ymlconf_config_neovim_tmux" == false ]] && {
  log 'applying tmux'
  echo "Settings.tmux = false" >>"$settings"
}
[[ "$ymlconf_config_neovim_floatingTerminal" == true ]] && {
  log 'applying floating terminal'
  echo "Settings.floating_terminal = true" >>"$settings"
}
[[ -v ymlconf_config_neovim_theme ]] && {
  log 'applying theme'
  echo "Settings.theme = '$ymlconf_config_neovim_theme'" >>"$settings"
}

langs=
for key in $(yaml_array_keys ymlconf_config_neovim_langs_); do
  langs+="'${!key}',"
done
! [[ -z "$langs" ]] && {
  log 'applying langs'
  echo "Settings.langs = { ${langs%?} }" >>"$settings"
}
exit 0
