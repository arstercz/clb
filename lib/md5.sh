# common use for md5sum

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/log.sh"
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workinit.sh"

md5_args() {
  md5sum <<<"$@" | awk '{print $1}'
}

md5_file() {
  local file="$1"
  if [ -e "$file" ]; then
    md5sum $file | awk '{print $1}'
  fi
  return 1
}

md5_check() {
  local file="$1"
  local is_print_log="$2"
  [ -e "$file" ] || return 1

  local res
  DATESIGN=$(date +%FT%T | tr ':' '_')
  MD5_LOGFILE="${WT_WORK_LOGS}/md5check-${DATESIGN}-$(basename $file)"

  # switch to file's dir
  pushd $(dirname "$file") >/dev/null 2>&1
  md5sum -c "$file" > $MD5_LOGFILE 2>&1
  res=$(($? + 0))
  popd >/dev/null 2>&1

  if [[ "$is_print_log" == "yes" && $res -gt 0 ]]; then
    cat $MD5_LOGFILE | grep -v "OK"
  fi

  return $res
}
