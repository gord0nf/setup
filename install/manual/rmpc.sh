#!/bin/bash

install_dir=$1
FORCE="${FORCE:-false}"

THING=rmpc
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

get_download_url() {
  local version=$1

  local os= arch=
  case "$(get_os)" in
  mac) os=apple-darwin ;;
  linux) os=unknown-linux-gnu ;;
  *) fatal 'os not supported' ;;
  esac
  case "$(get_arch)" in
  amd/x64) arch=x86_64 ;;
  arm*) arch=aarch64 ;;
  *) fatal 'arch not supported' ;;
  esac

  echo "https://github.com/mierak/rmpc/releases/download/$version/rmpc-$version-$arch-$os.tar.gz"
}

if ! $FORCE && command_exists rmpc; then
  log 'already installed'
else
  log 'getting version'
  version=$(get_latest_github_tag 'mierak/rmpc')
  url=$(get_download_url "$version")

  log 'installing'
  atomic_download_and_extract "$url" "$install_dir" '' || fatal 'install failed'
  register "$install_dir/rmpc"
fi
