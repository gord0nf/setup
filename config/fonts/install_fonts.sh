#!/bin/bash

fonts=$(find "$(dirname "${BASH_SOURCE[0]}")" -type f \( -name "*.ttf" -o -name "*.otf" \))
[[ "$EUID" -eq 0 ]] && dest=/usr/share/fonts || dest=$HOME/.local/share/fonts
mkdir -p "$dest" &>/dev/null

for font in $fonts; do
  chmod 644 "$font" # https://wiki.debian.org/Fonts
  cp "$font" "$dest"
done

fc-cache
