#!/bin/bash

install_dir=$1
FORCE="${FORCE:-false}"

THING=ytdlp
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

get_download_url() {
  local ext=
  case "$(get_os)" in
  mac) ext=_macos ;;
  linux) ;;
  windows) ext=.exe ;;
  *) fatal 'os not supported' ;;
  esac

  echo "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp$ext"
}

if ! $FORCE && command_exists yt-dlp; then
  log 'already installed'
else
  log 'downloading'
  url=$(get_download_url)
  tmp=$(download "$url") || fatal 'download failed'
  target="$install_dir/yt-dlp"

  mkdir -p "$install_dir"
  mv "$tmp" "$target"
  chmod +x "$target"
  [[ "$tmp" == *.exe ]] && mv "$target" "$target.exe"
  rm -f "$tmp"

  register "$target"
fi
