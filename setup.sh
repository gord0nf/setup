#!/bin/bash

SOFTWARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SOFTWARE_DATA=$SOFTWARE_ROOT/_data
HELP=$'usage: setup.sh [opts] ...(things or setup scripts or yaml configs)

By default, failed installs fallback to the `manual` manager.

By default, the default yaml config is loaded. However, if things, scripts, or other yml configs
are passed as args or --no-default-yml-things, anything under under yml `setup:` is not run (but
yml `config:` settings stay). However, if --no-default-yml is passed, nothing from the default
yaml is loaded.

options:
 -c, --config-only       only run the config script for the things
 -f, --force             runs install/config scripts even if already installed/configed and doesn\'t ask before overwriting stuff
 -a, --all               runs scripts for anything that can be installed with the manager used
 -m, --manager <mgr>     run install script using a specific manager, defaults to first available
 -F, --fail              fatal exit if any install or config fails
 --no-fallback           do not fall back to the manual manager if install fails
 --no-default-yml        do not look for and use any yml configs other than explictly specified
 --no-default-yml-things load default yaml but do not use any things under `setup`'

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
  [[ " ${arr[*]} " =~ [[:space:]]$2[[:space:]] ]]
}

set_manager() {
  [[ -f "$SOFTWARE_ROOT/managers/$1.sh" ]] && main_manager=$1
}

add_thing() {
  local thing=$1 manager=$main_manager
  if [[ "$thing" =~ ^(.+)@(.+)$ ]]; then
    thing=${BASH_REMATCH[1]} manager=${BASH_REMATCH[2]}
    manager_exceptions[$thing]=$manager
  fi
  if [[ -f "$SOFTWARE_ROOT/install/$manager/$thing.sh" ]]; then
    ! has_element things "$thing" && things+=("$thing")
  else
    return 1
  fi
  return 0
}

load_yml_config() {
  local path=$1 no_things=${2:-false}

  # first look for other configs to extend
  while IFS= read -r extended; do
    if [[ "$extended" =~ ^preset:(.+)$ ]]; then
      extended="$SOFTWARE_ROOT/presets/${BASH_REMATCH[1]}.yml"
      [[ -f "$extended" ]] || fatal "no preset named '${BASH_REMATCH[1]}'"
    else
      case "$extended" in
      /* | ~/*) ;;
      *) extended="$(dirname "$path")/$extended" ;;
      esac
    fi
    load_yml_config "$extended" $no_things
  done < <(parse_yaml_noctx "$path" | sed -n -E "s/^extends(_[0-9]+)?='(.+)'$/\\2/p")

  # parse everything
  export $(parse_yaml "$path" ymlconf_ | xargs -L 1) || fatal "couldn't parse yaml at $path"

  if ! $no_things; then
    for key in $(yaml_array_keys ymlconf_setup_); do
      add_thing "${!key}" || warn "couldn't load install '${!key}' in $path"
    done
  fi
}

use_default_config() {
  local yml_config=$(
    find "$HOME" "$SOFTWARE_ROOT" \
      -type f \( -name software.yaml -o -name software.yml \) |
      head -n 1
  )

  # config in $SOFTWARE_DATA/profiles should take priority before $SOFTWARE/software.yml
  if [[ "$(dirname "$yml_config")" == "$SOFTWARE_ROOT" ]]; then
    for ext in yml yaml; do
      local profile_config="$SOFTWARE_DATA/profiles/$(whoami).$ext"
      [[ -f "$profile_config" ]] && {
        yml_config=$profile_config
        break
      }
    done
  fi

  ! [[ -z "$yml_config" ]] && {
    log "using config at $yml_config"
    load_yml_config "$yml_config" $no_default_yml_things
  }
}

# -------------------------------------------------------------------------------------------------
# parse args --------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# parse options ----------------------------------------------------------

main_manager=
config_only=false
all_things=false
no_default_yml=false
no_default_yml_things=false
manual_fallback=$(
  source "$SOFTWARE_ROOT/managers/manual.sh"
  manager_can_use &>/dev/null && echo true || echo false
)
fail=false
is_test=false

# pass to get manager
for ((i = 1; i <= $#; i++)); do
  arg=${!i}
  case "$arg" in
  --help | -h)
    echo "$HELP"
    exit
    ;;
  --manager | -m)
    ((i++))
    arg=${!i}
    [[ -z "$arg" ]] && fatal 'expected arg for --manager'
    set_manager "$arg" || fatal "invalid manager '$arg'"
    ;;
  --no-default-yml) no_default_yml=true ;;
  --no-default-yml-things) no_default_yml_things=true ;;
  --no-fallback) manual_fallback=false ;;
  --config-only | -c) config_only=true ;;
  --force | -f) export FORCE=true ;;
  --fail | -F) fail=true ;;
  --all | -a) all_things=true ;;
  --test) is_test=true ;;
  -*)
    echo "$HELP" >&2
    exit 1
    ;;
  *) no_default_yml_things=true ;;
  esac
done

# if not specified, use first usable manager
if [[ -z "$main_manager" ]]; then
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
  [[ -z "$main_manager" ]] && set_manager manual
fi

log "using '$main_manager' manager"
source "$SOFTWARE_ROOT/managers/$main_manager.sh"
manager_can_use || fatal "cannot use $main_manager manager on your system"

# parse main things ------------------------------------------------------

things=()
other_scripts=()
pre_commands=()
post_commands=()
declare -A manager_exceptions # hash table like [thing]=manager

# if set, load default config
! $no_default_yml && use_default_config

# if set, add all things (under main_manager)
$all_things &&
  for f in "$SOFTWARE_ROOT/install/$main_manager/"*.sh; do
    thing=$(basename -s '.sh' "$f")
    ! has_element things "$thing" && things+=("$thing")
  done

while (($# > 0)); do
  case "$1" in
  --manager | -m) shift ;;
  -*) ;;
  *)
    if is_script "$1"; then
      ! has_element other_scripts "$1" && other_scripts+=("$1")
    elif [[ -f "$1" ]]; then
      load_yml_config "$1"
    else
      add_thing "$1" || {
        warn "'$1' isn't a thing, preset, or script. skipping..."
        echo # style
      }
    fi
    ;;
  esac
  shift
done

# post processing --------------------------------------------------------

if $is_test; then
  echo -e "things (${#things[@]}): ${things[@]}\n"
  echo -e "other_scripts (${#other_scripts[@]}): ${other_scripts[@]}\n"
  echo 'config:'
  env | grep ^ymlconf_config_
  exit
fi

# custom scripts dir
script_dir="${XDG_CONFIG_HOME:-$HOME/.config}/scripts"
[[ -d "$script_dir" ]] || make_directory_link "$SOFTWARE_ROOT/config/scripts" "$script_dir"
add_global_path "$script_dir"

# if windows, set shell-agnostic $SOFTWARE env var (needed for configs of some windows things)
if [[ $(get_os) == windows ]] && command_exists powershell; then
  powershell -NoProfile -Command "[System.Environment]::SetEnvironmentVariable(
    'SOFTWARE',
    '$(convert_path_if_needed --windows "$SOFTWARE_ROOT")',
    [System.EnvironmentVariableTarget]::User
  )" || warn "couldn't set SOFTWARE sys env var, some Windows things might be iffy"
fi

# if linux, some basic bin dirs, just in case
for d in '/usr/local/bin/' "$HOME/.local/bin" "$HOME/bin"; do
  mkdir -p "$d" && add_global_path "$d"
done

# root yml config stuff --------------------------------------------------

[[ -v ymlconf_config_terminal ]] && set_global_env TERM "$ymlconf_config_terminal"
[[ -v ymlconf_config_editor ]] && set_global_env EDITOR "$(which "$ymlconf_config_editor")"

if [[ -v ymlconf_config_loginShell ]]; then
  shell_path=$(which "$ymlconf_config_loginShell")
  if [[ $(get_os) != windows ]]; then
    login_shell=$(basename $(getent passwd $(whoami) | cut -d: -f7))
    if [[ "$login_shell" != "$ymlconf_config_loginShell" ]]; then
      log "changing login shell to $ymlconf_config_loginShell"
      chsh -s "$shell_path"
    fi
  fi
  set_global_env SHELL "$shell_path"
fi

# -------------------------------------------------------------------------------------------------
# run stuff ---------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

[[ "${#things[@]}" -eq 0 && "${#other_scripts[@]}" -eq 0 ]] && fatal 'nothing to do'

# create necessary dirs
mkdir -p "$SOFTWARE_DATA/installed" "${XDG_CONFIG_HOME:-$HOME/.config}"

# preinstall -------------------------------------------------------------

for cmd in "${pre_commands[@]}"; do
  eval "$cmd" || fatal 'precommand failed'
done

command_exists manager_preinstall && {
  log 'running manager preinstall script'
  manager_preinstall || fatal 'manager preinstall failed'
}

# run main things --------------------------------------------------------

$fail && fail_cmd=fatal 'halt' || fail_cmd=continue

for thing in "${things[@]}"; do
  echo # separation line

  manager=${manager_exceptions[$thing]:-$main_manager}
  thing_install="$SOFTWARE_ROOT/install/$manager/$thing.sh"
  thing_config="$SOFTWARE_ROOT/config/$thing.sh"
  thing_install_dir="$SOFTWARE_DATA/installed/$thing"

  thing_manual_install=
  $manual_fallback && [[ $manager != manual ]] &&
    thing_manual_install="$SOFTWARE_ROOT/install/manual/$thing.sh"

  # install thing
  if ! $config_only; then
    log "$thing: installing"
    bash "$thing_install" "$thing_install_dir"
    log_result "$thing install" # preserves exit code
    if [[ $? -ne 0 ]]; then
      if [ -f "$thing_manual_install" ]; then
        warn "$thing install failed, falling back to manual install"
        bash "$thing_manual_install" "$thing_install_dir"
        log_result "$thing install"# preserves exit code
        [[ $? -eq 0 ]] || $fail_cmd
      else
        $fail_cmd
      fi
    fi
  fi

  # configure thing
  if [[ -e "$thing_config" ]]; then
    log "$thing: configuring"
    bash "$thing_config"
    log_result "$thing config"
    [[ $? -eq 0 ]] || $fail_cmd
  elif $config_only; then
    log "no config for $thing"
  fi
done

for script in "${other_scripts[@]}"; do
  log "script: $script"
  bash "$script" ''
  log_result "$script"
  [[ $? -eq 0 ]] || $fail_cmd
  echo # style
done

# postinstall ------------------------------------------------------------

for cmd in "${post_commands[@]}"; do
  eval "$cmd" || fatal 'postcommand failed'
done
