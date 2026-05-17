#!/bin/bash

# This is a template for a generic setup script that can be run by /setup.sh.
# /setup.sh expects usage like `_.sh <install_dir>`, with the FORCE env var specifying
# whether to force install.

install_dir=$1
FORCE="${FORCE:-false}"

THING=template
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

log 'this is an empty template'
