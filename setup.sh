#!/bin/bash

SOFTWARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
HELP=$'usage: setup.sh [opts] ...(things or setup scripts or presets)

options:
 -c, --config-only   only run the config script for the things
 -f, --force         runs install/config scripts even if already installed/configed and doesn\'t ask before overwriting stuff
 -a, --all           runs scripts for anything that can be installed with the manager used
 -m, --manager <mgr> run install script using a specific manager, defaults to first available
 --no-fallback       do not fall back to the manual manager if install fails'

# utils
source "$SOFTWARE_ROOT/utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

# logging
THING=software
PREFIX_COLOR="\033[34m"
PREFIX_FORMAT='%s:'
source "$SOFTWARE_ROOT/log.sh"

# helper functions --------------------------------------------------------------------------------

is_script() {
  [[ -f "$1" ]] && IFS= LC_ALL=C read -rN2 shebang <"$1" && [ "$shebang" = '#!' ]
}

has_element() {
  local -n arr=$1
  local el=$2
  [[ " ${arr[*]} " =~ [[:space:]]${el}[[:space:]] ]]
}

set_manager() {
  if [[ -f "$SOFTWARE_ROOT/managers/$1.sh" ]]; then
    manager=$1
  else
    return 1
  fi
}

add_thing() {
  if [[ -f "$SOFTWARE_ROOT/install/$manager/$1.sh" ]]; then
    ! has_element things "$1" && things+=("$1")
  else
    return 1
  fi
  return 0
}

get_preset_path() {
  if [[ -f "$1" ]]; then
    echo "$1"
  elif [[ -f "$SOFTWARE_ROOT/presets/$1" ]]; then
    echo "$SOFTWARE_ROOT/presets/$1"
  else
    return 1
  fi
}

load_preset() {
  local preset_path=$1
  local line_no=0

  while IFS=$'\r\n' read -r line; do
    ((line_no++))
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ extends:(.+) ]]; then
      local extended=$(get_preset_path "${BASH_REMATCH[1]}") && load_preset "$extended" ||
        warn "couldn't load line $line_no for $preset_path"
    elif [[ "$line" =~ pre:(.+) ]]; then
      pre_commands+=("${BASH_REMATCH[1]}")
    elif [[ "$line" =~ post:(.+) ]]; then
      post_commands+=("${BASH_REMATCH[1]}")
    else
      add_thing "$line" || warn "couldn't load line $line_no for $preset_path"
    fi
  done <"$preset_path"
}

# parse args --------------------------------------------------------------------------------------

manager=
install=true
manual_fallback=$(
  source "$SOFTWARE_ROOT/managers/manual.sh"
  manager_can_use &>/dev/null && echo true || echo false
)
things=()
other_scripts=()
pre_commands=()
post_commands=()

# initial pass to get manager
for ((i = 0; i < $#; i++)); do
  arg=${!i}
  case "$arg" in
  --manager | -m)
    ((i++))
    arg=${!i}
    [[ -z "$arg" ]] && fatal 'expected arg for --manager'
    set_manager "$arg" || fatal "invalid manager '$arg'"
    ;;
  esac
done

# if not specified, use first usable manager
if [[ -z "$manager" ]]; then
  log "no manager specified, defaulting to one"
  for manager_script in $(ls "$SOFTWARE_ROOT/managers/"*.sh); do
    [[ "$manager_script" == */manual.sh ]] && continue # save manual for last
    manager_script=$(
      source "$manager_script"
      manager_can_use &>/dev/null && echo "$manager_script"
    )
    ! [[ -z "$manager_script" ]] && {
      set_manager "$(basename -s .sh "$manager_script")"
      break
    }
  done
  [[ -z "$manager" ]] && {
    set_manager manual
    manual_fallback=false
  }
fi

while (($# > 0)); do
  case "$1" in
  --help | -h)
    echo "$HELP"
    exit
    ;;
  --manager | -m)
    shift
    shift
    ;;
  --no-fallback)
    manual_fallback=false
    shift
    ;;
  --config-only | -c)
    install=false
    shift
    ;;
  --force | -f)
    export FORCE=true
    shift
    ;;
  --all | -a)
    for f in "$SOFTWARE_ROOT/install/$manager/"*.sh; do
      thing=$(basename -s '.sh' "$f")
      if ! has_element things "$thing"; then
        things+=("$thing")
      fi
    done
    shift
    ;;
  -*)
    echo "$HELP" >&2
    exit 1
    ;;
  *)
    if is_script "$1"; then
      ! has_element other_scripts "$1" && other_scripts+=("$1")
    elif preset_path=$(get_preset_path "$1"); then
      load_preset "$preset_path"
    else
      add_thing "$1" || {
        warn "'$1' isn't a thing, preset, or script. skipping..."
        echo # style
      }
    fi
    shift
    ;;
  esac
done

# create dir for installed things
if ! [[ -d "$SOFTWARE_ROOT/installed" ]]; then
  mkdir "$SOFTWARE_ROOT/installed"
fi

# if windows, set shell-agnostic $SOFTWARE env var (needed for configs of some windows things)
if [[ $(get_os) == windows ]] && command_exists powershell; then
  powershell -NoProfile -Command "[System.Environment]::SetEnvironmentVariable(
    'SOFTWARE',
    '$(convert_path_if_needed --windows "$SOFTWARE_ROOT")',
    [System.EnvironmentVariableTarget]::User
  )" || warn "couldn't set SOFTWARE sys env var, some Windows things might be iffy"
fi

# run scripts -------------------------------------------------------------------------------------

log "using '$manager' manager"
source "$SOFTWARE_ROOT/managers/$manager.sh"
manager_can_use || fatal "cannot use $manager manager on your system"

for cmd in "${pre_commands[@]}"; do
  eval "$cmd" || fatal 'precommand failed'
done

command_exists manager_preinstall && {
  log 'running manager preinstall script'
  manager_preinstall
}

echo # style

for thing in "${things[@]}"; do
  [[ "$thing" != "${things[0]}" ]] && echo # separation line

  thing_install="$SOFTWARE_ROOT/install/$manager/$thing.sh"
  thing_manual_install="$SOFTWARE_ROOT/install/manual/$thing.sh"
  thing_config="$SOFTWARE_ROOT/config/$thing.sh"
  thing_install_dir="$SOFTWARE_ROOT/installed/$thing"

  if $install; then
    log "$thing: installing"
    bash "$thing_install" "$thing_install_dir" && log_result "$thing install" || {
      if $manual_fallback && [[ -f "$thing_manual_install" ]]; then
        warn "$thing install failed, falling back to manual install"
        bash "$thing_manual_install" "$thing_install_dir" && log_result "$thing install" || {
          log_result "$thing install"
          continue
        }
      else
        log_result "$thing install"
        continue
      fi
    }
  fi

  if [[ -e "$thing_config" ]]; then
    log "$thing: configuring"
    bash "$thing_config"
    log_result "$thing config"
  elif ! $install; then
    log "no config for $thing"
  fi
done

for script in "${other_scripts[@]}"; do
  log "script: $script"
  bash "$script" ''
  log_result "$script"
  echo # style
done

for cmd in "${post_commands[@]}"; do
  eval "$cmd" || fatal 'postcommand failed'
done
