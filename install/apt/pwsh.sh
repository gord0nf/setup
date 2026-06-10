#!/bin/bash

THING=pwsh
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

${APT:-apt} install -y powershell || fatal 'install failed'
