# common use for redis

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/log.sh"
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workinit.sh"

OPT_HOST="${OPT_HOST:-"127.0.0.1"}"
OPT_PORT="${OPT_PORT:-"6379"}"
OPT_PASS="${OPT_PASS:-""}"

REDIS_STATLOG="${REDIS_STATLOG:-""}"
CMD_CONFIG="${CMD_CONFIG:-"config"}"

redis_exec() {
  export REDIS_CMD="$1"
  export REDIS_HOST=${OPT_HOST}
  export REDIS_PORT=${OPT_PORT}
  export REDIS_PASS=${OPT_PASS}

  perl -MIO::Socket::INET -e '
    my $pass = $ENV{REDIS_PASS};
    my $cmd  = length($pass)
             ? "auth $pass\r\n$ENV{REDIS_CMD}\r\nquit\r\n"
             : "$ENV{REDIS_CMD}\r\nquit\r\n";

    my $socket = IO::Socket::INET->new(
       PeerAddr => "$ENV{REDIS_HOST}",
       PeerPort => "$ENV{REDIS_PORT}",
       Proto    => "tcp",
       Timeout  => 2,
    ) or die "unable to connect $ENV{REDIS_HOST}:$ENV{REDIS_HOST}";

    print $socket "$cmd";
    local $/ = "\r\n";
    while(<$socket>) {
      # https://redis.io/topics/protocol
      die "redis error: $_" if /^\-/;
      next if /^[\+\:\$\*]/;
      next if /^(?:\bdir\b|\bdbfilename\b|\bappendfilename\b)/;

      chomp;
      print "$_\n";
    }
  '
}

_redis_dbfile() {
  local status=0
  local dbfile=""

  local dir=$(redis_exec "${CMD_CONFIG} get dir")
  [[ -z "$dir" ]] && return 1

  local file=$(redis_exec "${CMD_CONFIG} get dbfilename")
  if (($? == 0)); then
    dbfile="${dir}/${file}"
    status=0
  else
    status=2
  fi

  if (($status > 0)); then
    printf ""
  else
    printf "rdbfile:%s\n" $dbfile
  fi

  file=$(redis_exec "${CMD_CONFIG} get appendfilename")
  if (($? == 0)); then
    dbfile="${dir}/${file}"
    status=0
  else
    status=3
  fi

  if (($status > 0)); then
    printf ""
  else
    printf "aoffile:%s\n" $dbfile
  fi

  return $status
}

_redis_common_info() {
  local status=0
  REDIS_ERRLOG="${WT_WORK_LOGS}/redis_${OPT_HOST}-${OPT_PORT}.error.log"
  if ! redis_exec "info all" > "${REDIS_STATLOG}" 2>${REDIS_ERRLOG}; then
    error "get redis info all error"
    status=1
  fi

  if ! _redis_dbfile >> "${REDIS_STATLOG}" 2>>${REDIS_ERRLOG}; then
    error "get dbfile error"
    status=2
  fi

  if redis_is_cluster; then
    if ! redis_exec "cluster info" >> "${REDIS_STATLOG}" 2>>${REDIS_ERRLOG}; then
      warn "get cluster info error"
      status=3
    fi
  fi

  return $status
}

_redis_info() {
  REDIS_STATLOG="${WT_WORK_TEMP}/redis_${OPT_HOST}-${OPT_PORT}_status.temp"
  if [ -s "${REDIS_STATLOG}" ]; then
    TIMECACHE=$(stat -c %Y "${REDIS_STATLOG}")
    TIMENOW=$(date +%s)
    if (($TIMENOW - $TIMECACHE > 60)); then
      unlink "${REDIS_STATLOG}"
      _redis_common_info
    fi
  else
    _redis_common_info
  fi
}

# is running or connectable
redis_is_ok() {
  local msg=""
  msg=$(redis_exec "echo ok")
  [[ "$msg" == "ok" ]]
}

redis_item_get() {
  local item="$1"
  if _redis_info; then
    cat ${REDIS_STATLOG} | grep "${item}:" | cut -d':' -f2
  fi
}

redis_is_slave() {
  local role=$(redis_item_get "role")
  [[ "$role" == "slave" ]]
}

redis_is_slave_ok() {
  if redis_is_slave; then
    SUP=$(redis_item_get "master_link_status")
    [[ "$SUP" == "up" ]]
  else
    return 1
  fi
}

redis_is_cluster() {
  local is_cluster=$(redis_item_get "cluster_enabled")
  (($is_cluster == 1))
}

redis_is_cluster_ok() {
  if redis_is_cluster; then
    CSTATE=$(redis_item_get "cluster_state")
    CSFAIL=$(redis_item_get "cluster_slots_fail")
    [[ "$CSTATE" == "ok" && "$CSFAIL" -eq 0 ]]
  else
    warn "redis ${OPT_HOST}:${OPT_PORT} is not cluster"
    return 1
  fi
}

# is redis in loading
redis_is_in_loading() {
  local is_loading=$(redis_item_get "loading")
  (($is_loading == 1))
}

redis_is_in_bgsave() {
  local is_bgsave=$(redis_item_get "rdb_bgsave_in_progress")
  (($is_bgsave == 1))
}

_redis_seconds_since_last_save() {
  local last_save_status=$(redis_item_get "rdb_last_bgsave_status")
  if [[ "${last_save_status}" == "ok" ]]; then
    local time_now=$(date +%s)
    local last_save_time=$(redis_item_get "rdb_last_save_time")
    
    printf "%d\n" $((time_now - $last_save_time))
  else
    printf "999999\n"  # should be save if last save error
  fi
}

# trigger bgsave if since_last_save older than threshold
redis_trigger_bgsave() {
  local threshold="${1:-7200}" # defauls is 2 hours
  local duration_second=$(_redis_seconds_since_last_save)

  if ((${duration_second} > $threshold)); then
    redis_exec "bgsave"
  fi
}

redis_is_aof_enable() {
  local is_aof=$(redis_item_get "aof_enabled")
  (($is_aof == 1))
}

redis_is_aof_in_rewrite() {
  local is_rewrite=$(redis_item_get "aof_rewrite_in_progress")
  (($is_rewrite == 1))
}

redis_trigger_aofrewrite() {
  if ! redis_is_aof_in_rewrite; then
    redis_exec "bgrewriteaof"
  fi
}

redis_is_memory_ok() {
  local threshold="${1:-"90"}"
  local memory_used=$(redis_item_get "used_memory")
  local memory_max=$(redis_item_get "maxmemory")

  local used_percent=$((memory_used * 100 / ${memory_max}))
  ((${used_percent} < $threshold))
}

redis_get_rdbfile() {
  local rdbfile=""
  rdbfile=$(redis_item_get "rdbfile")
  printf "%s" $rdbfile
}

redis_get_aoffile() {
  local aoffile=""
  aoffile=$(redis_item_get "aoffile")
  printf "%s" $aoffile
}
