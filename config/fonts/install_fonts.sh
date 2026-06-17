#!/bin/bash

fonts=$(find "$(dirname "${BASH_SOURCE[0]}")" -type f \( -name "*.ttf" -o -name "*.otf" \))
[[ "$EUID" -eq 0 ]] && fontdir=/usr/share/fonts || fontdir=$HOME/.local/share/fonts
mkdir -p "$fontdir"

for font in $fonts; do
  dest="$fontdir/$(basename "$font")"
  cp "$font" "$dest"
  chmod 644 "$dest" # https://wiki.debian.org/Fonts
done

fc-cache || sudo fc-cache
