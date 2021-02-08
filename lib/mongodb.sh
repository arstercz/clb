# common method for mongodb

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/log.sh"
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workinit.sh"

OPT_HOST="${OPT_HOST:-"127.0.0.1"}"
OPT_PORT="${OPT_PORT:-"27017"}"
DIRECT_DEV="/dev/null"

mongo_exec() {
  [ "$DEBUG" ] && DIRECT_DEV="/dev/stderr"

  timeout 5 \
    mongo ${OPT_HOST:+--host="${OPT_HOST}"} ${OPT_PORT:+--port="${OPT_PORT}"} \
          ${OPT_USER:+--username="${OPT_USER}"} ${OPT_PASS:+--password="${OPT_PASS}"} \
          ${OPT_AUTHDB:+--authenticationDatabase="${OPT_AUTHDB}"} \
          --quiet --eval "$1" 2>$DIRECT_DEV
}

mongo_is_alive() {
  local res=$(mongo_exec "db.stats().ok")
  if [[ "$res" == "1" ]]; then
    return 0  # is alive
  else
    return 1  # is dead
  fi
}

#instance role maybe 
#  primary
#  secondary
#  arbiter
#  master  -> can also be single node
#  slave

mongo_is_replset() {
  local res=$(mongo_exec "rs.status().set")
  if [[ -n "$res" ]]; then
    return 0
  else
    return 1
  fi
}

mongo_role_name() {
  local role="unknown";
  if mongo_is_replset; then
    local res1=$(mongo_exec "rs.isMaster().ismaster")
    local res2=$(mongo_exec "rs.isMaster().secondary")
    if [[ "$res1" == "true" ]]; then
      role="primary"
    elif [[ "$res2" == "true" ]]; then
      role="secondary"
    elif [[ $res1 == "false" && $res2 == "false" ]]; then
      role="arbiter"
    else
      role="unknown"
    fi
  else
    local res=$(mongo_exec "rs.isMaster().ismaster")
    if [[ "$res" == "true" ]]; then
      role="master"
    else
      role="slave"
    fi
  fi
  printf "%s" $role
}

mongo_get_repl_lag() {
  local role="$1"
  if [[ "$role" == "slave" ]]; then
    mongo_exec "db.printReplicationInfo()" | \
       grep 'behind the freshest' | \
       perl -ne 'print $1 if /(\d+?)\ssecs\s/i'
  fi

  if [[ "$role" == "secondary" ]]; then
    local self_host=$(mongo_exec "rs.status().members.forEach(function(op) { if (op.self == true) {printjson(op.name)} })")
    export SELF_HOST=$self_host
    mongo_exec "db.printSlaveReplicationInfo()" | \
       perl -ne '
         BEGIN {
           my $host = $ENV{SELF_HOST};
           $host =~ s/"//g;
         };

         chomp;
         print $1 if /(\d+)\ssecs\s.+behind the/ && $match == 1; 
         $match = 1 if /$host/
       '
  fi

}

mongo_is_repl() {
  local role=$(mongo_role_name)
  [[ "$role" == "slave" || "$role" == "secondary" ]]
}

mongo_is_repl_ok() {
  local threshold="$1"
  threshold="${threshold:-150}" # default is 150 seconds
  local role=$(mongo_role_name)

  mongo_is_repl || return 1 # not repl
  local lag=$(mongo_get_repl_lag "$role")
  lag="${lag:-99999}"
  if (($lag >= $threshold)); then
    return 1
  fi
  return 0
}

mongo_is_slave() {
  local role=$(mongo_role_name)
  [[ "$role" == "slave" ]]
}

mongo_is_slave_ok() {
  local threshold="$1"
  threshold="${threshold:-150}" # default is 150 seconds

  mongo_is_slave || return 1 # not slave

  local lag=$(mongo_get_repl_lag "slave")
  lag="${lag:-99999}"
  if (($lag >= $threshold)); then
    return 1
  fi
  return 0
}

mongo_is_secondary() {
  local role=$(mongo_role_name)
  [[ "$role" == "secondary" ]]
}

mongo_is_secondary_ok() {
  local threshold="$1"
  threshold="${threshold:-150}" # default is 150 seconds

  mongo_is_secondary || return 1 # not secondary

  local lag=$(mongo_get_repl_lag "secondary")
  lag="${lag:-99999}"
  if (($lag >= $threshold)); then
    return 1
  fi
  return 0
}

mongo_has_long_running() {
  local threshold="$1"
  threshold="${threshold:-10}"
  local num=$(mongo_exec "db.currentOp().inprog.forEach(function(op) { if (op.secs_running > $threshold && op.ns != 'local.oplog.\$main') printjson(op.ns)})" | wc -l)

  if (($num >= 3)); then
    return 0
  else
    return 1
  fi
}

mongo_has_lock() {
  local threshold="$1"
  local num=$(mongo_exec "db.currentOp({'waitingForLock': true}).inprog.forEach(function(op) { printjson(op.ns) })" | wc -l)
  threshold="${threshold:-3}"

  if (($num >= $threshold)); then
    return 0
  else
    return 1
  fi
}

mongo_backup() {
  local DB_NAME="$1"
  local CL_NAME="$2"

  local DSTDIR
  local VAL_DATABASE
  local VAL_COLLECTION
  local VAL_MASTER
  local VAL_SLAVE
  local VAL_SECONDARY
  local VAL_OPLOG=1

  if [[ -n "$DB_NAME" ]]; then
    VAL_DATABASE=1
    VAL_OPLOG="" # oplog only support all database
    [[ -n "$CL_NAME" ]] && VAL_COLLECTION=1
  fi

  if mongo_is_slave; then
    VAL_SLAVE=1
    VAL_OPLOG="" # slave does not support oplog
  fi

  if mongo_is_secondary; then
    VAL_SECONDARY=1
  fi

  DATESIGN=$(date +%FT%T | tr ':' '_')
  DUMPLOG="${WT_WORK_LOGS}/mongodump-${DATESIGN}-${OPT_HOST}_${OPT_PORT}.log"
  DSTDIR="${WT_WORK_DATA}/mongodump-${DATESIGN}-${OPT_HOST}_${OPT_PORT}"
  DSTDIR="${DSTDIR}${VAL_DATABASE:+"_${DB_NAME}"}${VAL_COLLECTION:+"_${CL_NAME}"}"

  mongodump ${OPT_HOST:+--host="${OPT_HOST}"} ${OPT_PORT:+--port="${OPT_PORT}"} \
            ${OPT_USER:+--username="${OPT_USER}"} ${OPT_PASS:+--password="${OPT_PASS}"} \
            ${OPT_AUTHDB:+--authenticationDatabase="${OPT_AUTHDB}"} \
            ${VAL_DATABASE:+--db="${DB_NAME}"} ${VAL_COLLECTION:+--collection="$CL_NAME"} \
            --numParallelCollections=4 ${VAL_OPLOG:+--oplog} \
            --out=$DSTDIR >$DUMPLOG 2>&1

  if (($? > 0)); then
    warn "mongodump $OPT_HOST:$OPT_PORT error!"
    return 1 # backup error
  fi
  log "mongodump $OPT_HOST:$OPT_PORT ok"
  return 0

}
