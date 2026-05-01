#!/bin/bash

THING=powershell
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

apt install -y powershell || fatal 'install failed'

log 'running initial setup'
pwsh -NoProfile -Command "$(dirname "${BASH_SOURCE[0]}")/../Setup-Powershell.ps1"
