#!/bin/bash

FORCE="${FORCE:-false}"
THING=brave
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

[[ $EUID -eq 0 ]] && curl='curl' || {
  warn 'requires sudo to install apt source'
  curl='sudo curl'
}

log 'installing apt sources'
$curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
  https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
$curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
  https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

log 'installing brave-browser'
${APT:-apt} update
${APT:-apt} install -y brave-browser
