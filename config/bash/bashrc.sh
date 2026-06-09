export BASH_CONFIG=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
export SOFTWARE="$(realpath "$BASH_CONFIG/../../")" # @gord0nf/software specific

export TERM=xterm-256color
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export LANG="en_US.UTF-8"

source "$BASH_CONFIG/utils.sh"

# env vars --------------------------------------------------------------------------------------------

if [[ -f "$HOME/.env" ]]; then
  line_regex='^([^=+]+)(\+?)=(.*)$'
  while IFS= read -r line; do
    [[ -z "${line// /}" || "$line" == '#'* ]] && continue
    if [[ "$line" =~ $line_regex ]]; then
      name=${BASH_REMATCH[1]}
      case "${BASH_REMATCH[2]}" in
      +) export "$name"="${!name}${BASH_REMATCH[3]}" ;;
      *) export "$name"="${BASH_REMATCH[3]}" ;;
      esac
    fi
  done <"$HOME/.env"
fi

# oh-my-posh --------------------------------------------------------------------------------------

if command_exists oh-my-posh; then
  for conf in custom half-life takuya; do
    conf="$SOFTWARE/config/ohmyposh/$conf.omp.json"
    if [[ -f "$conf" ]]; then
      eval "$(oh-my-posh init bash --config "$conf")"
      break
    fi
  done
fi

# prettier ----------------------------------------------------------------------------------------

PRETTIERD_DEFAULT_CONFIG="$SOFTWARE/config/nodejs/prettierrc.json"

# -------------------------------------------------------------------------------------------------

source "$BASH_CONFIG/aliases.sh"
