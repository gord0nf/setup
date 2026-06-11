export BASH_CONFIG=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

source "$BASH_CONFIG/.bashrc"

# Sway launch behavior ----------------------------------------------------------------------------

if [[ -v SWAY_START && "$(tty)" == "/dev/tty1" ]]; then
  if [[ "$SWAY_START" == 'prompt' ]]; then
    read -p "Start Sway? [y]es or [n]o: " -n 1 -r -t 1 reply
    echo
    if [[ ${reply:-y} =~ ^[Yy]$ ]]; then
      "$BASH_CONFIG/../sway/start-sway"
    fi
  else
    "$BASH_CONFIG/../sway/start-sway"
  fi
fi
