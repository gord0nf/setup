#!/bin/bash

THING=neovim
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

command_exists nvim && {
  log 'already installed'
  exit
}

$APT install -y make neovim
