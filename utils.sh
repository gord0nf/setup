SOFTWARE_SRC=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
GLOBAL_ENV="$SOFTWARE_SRC/.env.global"

# logging functions
! [[ -z "$THING" ]] && source "$SOFTWARE_SRC/log.sh"

# returns 'windows' | 'linux' | 'mac'
get_os() {
  if grep -qEi "(Microsoft|WSL|MSYS)" /proc/version &>/dev/null; then
    echo windows
  else
    case "$OSTYPE" in
    darwin*) echo mac ;;
    solaris* | linux* | bsd* | freebsd*) echo linux ;;
    msys* | cygwin* | win32*) echo windows ;;
    *)
      echo 'could not determine os. please define OSTYPE' >&2
      exit 1
      ;;
    esac
  fi
}

# returns 'amd/x64' | 'x32' | 'arm' | 'arm64'
get_arch() {
  local arch=
  if command_exists uname; then
    case "$(uname -m | tr '[:upper:]' '[:lower:]')" in
    x86_64) arch=amd/x64 ;;
    armv*) arch=arm ;;
    arm64 | aarch64) arch=arm64 ;;
    esac
  fi
  if [[ -z "$arch" ]] && command_exists arch; then
    case "$(arch)" in
    x86_64*) arch=amd/x64 ;;
    i*86) arch=x32 ;;
    arm*) arch=arm ;;
    esac
  fi
  if [[ -z "$arch" ]]; then
    echo 'could not determine arch.' >&2
    exit 1
  fi

  if [ "${arch}" = "arm64" ] && command_exists getconf && [ "$(getconf LONG_BIT)" -eq 32 ]; then
    arch=arm
  fi
  echo "$arch"
}

is_android() {
  [[ "$PREFIX" == *com.termux* ]] || command_exists termux-setup-storage
}

command_exists() {
  local command=$1
  if command -v $command &>/dev/null; then
    return 0
  fi
  return 1
}

# git bash on windows is iffy about detecting junctions as existing using just [ -e ... ]
item_exists() {
  [[ -e "$1" ]] || ls "$1" &>/dev/null
}

convert_path_if_needed() {
  local target_switch=$1
  local path=$2
  if command_exists wslpath; then
    echo "$(wslpath $target_switch "$path")"
  elif command_exists cygpath; then
    echo "$(cygpath $target_switch "$path")"
  else
    echo "$path"
  fi
}

make_directory_link() {
  local actual=$(convert_path_if_needed --unix "$1")
  local link=$(convert_path_if_needed --unix "$2")
  FORCE="${FORCE:-false}"

  if item_exists "$link"; then
    if ! $FORCE; then
      echo "mklink: something's already at link '$link'"
      read -p "mklink: want to replace it? (y/n) [n] " yn
      case $yn in
      [Yy]*) ;;
      *) exit 1 ;;
      esac
    fi

    rm -fr "$link"
  fi

  if [[ $(get_os) != 'windows' ]]; then
    ln -s "$actual" "$link"
  else
    actual=$(convert_path_if_needed --windows "$actual")
    link=$(convert_path_if_needed --windows "$link")
    local cmd="cmd /C'mklink /j ""$link"" ""$actual""'"
    printf 'mklink: '
    eval "$cmd"
  fi
}

download() {
  local url=$1
  local tmp=$(mktemp)
  curl --ssl-revoke-best-effort --fail -L -o "$tmp" "$url"
  echo "$tmp"
}

# returns with 0 if success, 1 if download failed, 2 if extract failed
download_and_extract() {
  local url=$1
  local outdir=$2
  local archive_type=$3 # "zip" | "tar"; optional, falls back to url filename

  local tmp=$(download "$url") || return 1

  if [[ "$archive_type" == '' ]]; then
    case "$url" in
    *.zip) archive_type=zip ;;
    *.tar | *.tar.gz | *.tar.xz) archive_type=tar ;;
    *)
      echo 'extract: could not determine archive type from url' >&2
      return 2
      ;;
    esac
  fi

  case "$archive_type" in
  zip)
    if ! unzip "$tmp" -d "$outdir"; then
      return 2
    fi
    ;;
  tar)
    if ! tar -xf "$tmp" -C "$outdir"; then
      return 2
    fi
    ;;
  *)
    echo 'extract: invalid archive_type' >&2
    return 2
    ;;
  esac

  rm -f "$tmp"

  # remove nested root dirs until the outdir is the root dir
  while true; do
    items=$(ls -A "$outdir")
    rootdir="$outdir/${items[0]}"
    if (("${#items[@]}" == 1)) && [[ -d "$rootdir" ]]; then
      mv "$rootdir"/* "$rootdir"/.* "$outdir" &>/dev/null
      rmdir "$rootdir"
    else
      break
    fi
  done
}

atomic_download_and_extract() {
  local url=$1
  local outdir=$2
  local tmpoutdir="$(dirname "$outdir")/unfinished_$(basename "$outdir")"
  local archive_type=$3 # "zip" | "tar"; optional, falls back to url filename
  FORCE="${FORCE:-false}"

  if item_exists "$outdir" && ! $FORCE; then
    echo "extract: something's already at outdir '$outdir'"
    read -p "extract: want to replace it? (y/n) [n] " yn
    case $yn in
    [Yy]*) ;;
    *) exit 1 ;;
    esac
  fi

  mkdir -p "$tmpoutdir"
  download_and_extract "$url" "$tmpoutdir" "$archive_type" || {
    local exitstatus=$?
    if item_exists "$tmpoutdir"; then
      rm -fr "$tmpoutdir"
    fi
    return $exitstatus
  }

  if item_exists "$outdir"; then
    rm -fr "$outdir"
  fi
  mv "$tmpoutdir" "$outdir"
}

get_latest_github_tag() {
  local repo=$1
  curl "https://api.github.com/repos/$repo/releases/latest" |
    grep -E -o '.*"tag_name".*:.+' |
    sed 's/^.*:\s*"\(.*\)".*$/\1/'
}

# interface for variables in .env.global (with special += syntax for appending)
set_global_env() {
  local name=$1
  local value=$2
  local global_env=
  [[ -f "$GLOBAL_ENV" ]] || touch "$GLOBAL_ENV"

  if [[ "$3" == "-a"* ]]; then
    export "$name"="${!name}$value"
    grep -qE "^$name\\+=" "$GLOBAL_ENV" &&
      sed -i "/^$name+=/s/$/$value/" "$GLOBAL_ENV" ||
      echo "$name+=$value" >>"$GLOBAL_ENV"
  else
    export "$name"="$value"
    sed -i "/^$name=/d" "$GLOBAL_ENV"
    echo "$name=$value" >>"$GLOBAL_ENV"
  fi
}

add_global_path() {
  local p=$(convert_path_if_needed --unix "$1") # global PATH stored in unix format
  local global_PATH=$(sed -n 's/^PATH+=\(.*\)/\1/p' "$GLOBAL_ENV")
  if [ -d "$p" ] && [[ ":$global_PATH:" != *":$p:"* ]]; then
    set_global_env PATH ":$p" -append
  fi
}

register() {
  local target_bin=$1

  if [[ -f "$target_bin" || -f "$target_bin.exe" ]]; then
    local bin_dir=$(dirname "$target_bin")
    case $(get_os) in
    windows) add_global_path "$bin_dir" ;;
    *)
      [[ $EUID -eq 0 ]] && symlink_dir='/usr/local/bin/' || symlink_dir="$HOME/.local/bin"
      add_global_path "$symlink_dir" # just in case
      ln --symbolic "$target_bin" "$symlink_dir/$(basename "$target_bin")"
      ;;
    esac
  fi
}
