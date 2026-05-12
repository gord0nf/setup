export ZSH_CONFIG=${0:A:h}
export SOFTWARE="$(realpath "$ZSH_CONFIG/../../")" # @gord0nf/software specific

# path --------------------------------------------------------------------------------------------

if [[ -f "$SOFTWARE/software.csv" ]]; then
  skip_headers=1
  while IFS=, read -r name version paths; do
    if ((skip_headers)); then
      ((skip_headers--))
    else
      paths=${paths//|/ }
      for path in $paths; do
        export PATH="$PATH:$(convert_path_if_needed --unix "$path")"
      done
    fi
  done <"$SOFTWARE/software.csv"
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
