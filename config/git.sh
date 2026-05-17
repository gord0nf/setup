#!/bin/bash

FORCE="${FORCE:-false}"
THING=git
CONFIG="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$THING"
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

! $FORCE && ! command_exists git && fatal 'not installed'

log 'including config in global .gitconfig'
git config set --global include.path "$CONFIG/gitconfig"
