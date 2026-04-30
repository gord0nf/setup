MANAGER=apt
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

manager_can_use() {
  command_exists apt || {
    err "manager($MANAGER): requires apt, but not found"
    return 1
  }
}

manager_preinstall() {
  apt update
}
