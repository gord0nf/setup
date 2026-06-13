MANAGER=apt
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

export APT=apt

manager_can_use() {
  command_exists apt || {
    err "manager($MANAGER): requires apt, but not found"
    return 1
  }
}

if [[ "$config_only" != true ]]; then
  manager_preinstall() {
    $APT update || {
      if [[ $APT != sudo* && $EUID -ne 0 ]]; then
        log 'sudo required to install with apt'
        export APT='sudo apt'
        $APT update || return 1

        # sudo keepalive
        while true; do
          sudo -n true
          sleep 60
          kill -0 "$$" || exit
        done 2>/dev/null &
      fi
    }
  }
fi
