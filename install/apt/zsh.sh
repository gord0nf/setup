#!/bin/bash

install_dir=$1
FORCE="${FORCE:-false}"

THING=zsh
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

${APT:-apt} install -y zsh || fatal 'install failed'

# make sure install dir does not exist
if item_exists "$install_dir"; then
  if ! $FORCE; then
    warn "something's already at '$install_dir'"
    read -p "want to replace it? (y/n) [n] " yn -r 1
    [[ "$yn" == [Yy]* ]] || fatal 'aborted'
  fi
  rm -fr "$install_dir"
fi

log 'installing oh-my-zsh'
install_script=$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)
ZSH="$install_dir" sh -c "$install_script" '' --unattended && {

  # make dir link to standard oh-my-zsh location in home
  log "creating directory link from ~/.oh-my-zsh to '$install_dir'"
  make_directory_link "$install_dir" "$HOME/.oh-my-zsh"

  # install basic plugins
  log 'installing zsh-autoseggestions'
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  log 'installing zsh-syntax-highlighting'
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  log 'installing powerlevel10k'
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

}
