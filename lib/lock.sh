# common use for md5sum

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/md5.sh"
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workinit.sh"

declare -a WT_PARAMS=($0 "$@")
WT_LOCKFILE=""

# default lock prefix
_gen_short_md5() {
  md5_args "${WT_PARAMS[@]}" | cut -c 1-10
}

lock_is_ok() {
  local fd=99
  [ -z "${WT_LOCKFILE}" ] && {
    local prefix="$(_gen_short_md5)"
    WT_LOCKFILE="${WT_WORK_TEMP}/$prefix~$(whoami).lock-run"
  }
  # create lock file
  eval "exec $fd>${WT_LOCKFILE}"

  # acquier lock, timeout when execute greater then 1 second
  flock -w 1 -x -n $fd && {
    return 0
  } || {
    return 1
  }
}

lock_exit() {
  [ -e "${WT_LOCKFILE}" ] && unlink "${WT_LOCKFILE}"
}
