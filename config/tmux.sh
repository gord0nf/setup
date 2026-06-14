#!/bin/bash

FORCE="${FORCE:-false}"
THING=tmux
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists tmux && fatal 'not installed'

# create link tmux_dir to config
tmux_dir="${XDG_CONFIG_HOME:-~/.config}/tmux"
log "creating directory link from '$tmux_dir' to config"
make_directory_link "$CONFIG" "$tmux_dir"

# make sure ~/.tmux.conf is the entry point that sources config
log 'making sure ~/.tmux.conf sources'
src_line="source-file $tmux_dir/tmux.conf"
grep -qxF "$src_line" ~/.tmux.conf || echo "$src_line" >>~/.tmux.conf
