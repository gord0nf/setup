#!/bin/bash

# Sway launch behavior to be run in ~/.profile or equivalent

if [[ -v SWAY_START && "$(tty)" =~ /dev/tty[0-9] ]]; then
  start_sway="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/start-sway.sh"
  if [[ "$SWAY_START" == 'prompt' ]]; then
    read -p "Start Sway? [y]es or [n]o: " -n 1 -r -t 1 reply && echo
    [[ ${reply:-y} =~ ^[Yy]$ ]] && $start_sway
  else
    $start_sway
  fi
  unset start_sway
fi
