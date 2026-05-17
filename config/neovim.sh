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
    make_directory_link "$CONFIG" "$nvim_dir" $FORCE
  fi
done
