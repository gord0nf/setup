export ZSH_CONFIG=${0:A:h}
export SOFTWARE="$(realpath "$ZSH_CONFIG/../../")" # @gord0nf/software specific

# env vars ----------------------------------------------------------------------------------------

if [[ -f "$HOME/.env" ]]; then
  line_regex='^([^=+]+)(\+?)=(.*)$'
  while IFS= read -r line; do
    [[ -z "${line// /}" || "$line" == '#'* ]] && continue
    if [[ "$line" =~ $line_regex ]]; then
      name=${match[1]}
      case "${match[2]}" in
      +) export "$name"="${(P)name}${match[3]}" ;;
      *) export "$name"="${match[3]}" ;;
      esac
    fi
  done <"$HOME/.env"
fi

# oh-my-zsh configuration -------------------------------------------------------------------------

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#663399,standout"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

# prettier ----------------------------------------------------------------------------------------

PRETTIERD_DEFAULT_CONFIG="$SOFTWARE/config/nodejs/prettierrc.json"

# -------------------------------------------------------------------------------------------------

source "$ZSH_CONFIG/aliases.sh"
