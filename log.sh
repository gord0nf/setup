if [[ -z "$THING" ]]; then
  echo 'THING must be defined to use log.sh' >&2
  exit 1
fi

# random 256 color
[[ -z "$PREFIX_COLOR" ]] && PREFIX_COLOR="\033[38;5;$(shuf -i 67-231 -n 1)m"
[[ -z "$PREFIX_FORMAT" ]] && PREFIX_FORMAT='[%s]'

PREFIX=$(printf "%s$THING\033[0m" "$PREFIX_COLOR")
PREFIX=$(printf -- "$PREFIX_FORMAT" "$PREFIX")

log() {
  printf "$PREFIX %s\n" "$*" >&2
}

log_result() {
  local exit_code=$?
  printf "$PREFIX$(
    [ $exit_code -eq 0 ] &&
      echo " \033[32m%s success" ||
      echo " \033[31m%s failed"
  )\033[0m\n" "$*" >&2
  return $exit_code
}

warn() {
  printf "$PREFIX \033[33mwarning: %s\033[0m\n" "$*" >&2
}

err() {
  printf "$PREFIX \033[31m%s\033[0m\n" "$*" >&2
}

fatal() {
  err "fatal: $*"
  exit 1
}
