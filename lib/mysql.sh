# common use for mysql

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/log.sh"
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/workinit.sh"

OPT_HOST="${OPT_HOST:-"127.0.0.1"}"
OPT_PORT="${OPT_PORT:-"3306"}"
OPT_USER="${OPT_USER:-"root"}"
OPT_CHARSET="${OPT_CHARSET:-"utf8mb4"}"

DIRECT_DEV="/dev/null"
DEBUG="${DEBUG:-""}"

mysql_exec() {
  [ "$DEBUG" ] && DIRECT_DEV="/dev/stderr"

  mysql ${OPT_DEFT:+--defaults-file="${OPT_DEFT}"} \
        ${OPT_HOST:+-h"${OPT_HOST}"} ${OPT_PORT:+-P"${OPT_PORT}"} \
        ${OPT_USER:+-u"${OPT_USER}"} ${OPT_PASS:+-p"${OPT_PASS}"} \
        ${OPT_SOCK:+-S"${OPT_SOCK}"} \
        ${OPT_CHARSET:+"--default-character-set=${OPT_CHARSET}"}\
        --connect-timeout=3 -ss -e "$1" 2>$DIRECT_DEV
}

mysql_exec_by_cnf() {
  [ "$DEBUG" ] && DIRECT_DEV="/dev/stderr"

  OPT_PASS="${OPT_PASS:-""}"

  set -o pipefail
  printf \
    "%s\n" \
    "[client]" \
    "user=${OPT_USER}" \
    "password=${OPT_PASS}" \
    "host=${OPT_HOST}" \
    "port=${OPT_PORT}" \
    "default-character-set=${OPT_CHARSET}" \
      | \
      mysql ${OPT_DEFT:+--defaults-file="${OPT_DEFT}"} \
            "--defaults-extra-file=/dev/stdin" \
            ${OPT_SOCK:+-S"${OPT_SOCK}"} \
            --connect-timeout=3 -ss -e "$1" 2>$DIRECT_DEV
}

mysqldump_backup() {
  OPT_PASS="${OPT_PASS:-""}"

  local DB_NAME="$1"
  local TB_NAME="$2"

  local DSTFILE  
  local VAL_ALLDB
  local VAL_DATABASE
  local VAL_TABLES
  local VAL_TRANSACTION
  local VAL_LOCKBACKUP
  local VAL_MASTER
  local VAL_SLAVE
  # change option
  if mysql_is_all_innodb; then
    VAL_TRANSACTION=1
  fi

  # lock-for-backup, mostly support by percona server
  if mysqldump --lock-for-backups --version >/dev/null 2>&1; then
    VAL_LOCKBACKUP=1
  fi

  if [[ -n "$DB_NAME" ]]; then
    VAL_DATABASE=1
    if [[ -n "$TB_NAME" ]]; then
      VAL_TABLES=1
    fi
  else
    VAL_ALLDB=1
  fi

  if mysql_is_slave; then
    VAL_SLAVE=1
  else
    VAL_MASTER=1
  fi

  # change dest file name if already exists
  DATESIGN=$(date +%FT%T | tr ':' '_')
  DSTFILE="${WT_WORK_DATA}/mysqldump-${DATESIGN}-${OPT_HOST}_${OPT_PORT}"
  DSTFILE="${DSTFILE}${VAL_DATABASE:+"_${DB_NAME}"}${VAL_TABLES:+"_${TB_NAME}"}.sql"

  local error_log="${WT_WORK_LOGS}/mysqldump-${DATESIGN}-${OPT_HOST}_${OPT_PORT}.log"

  set -o pipefail
  printf \
    "%s\n" \
    "[client]" \
    "user=${OPT_USER}" \
    "password=${OPT_PASS}" \
    "host=${OPT_HOST}" \
    "port=${OPT_PORT}" \
    "default-character-set=${OPT_CHARSET}" \
      | \
      mysqldump ${OPT_DEFT:+--defaults-file="${OPT_DEFT}"} \
                "--defaults-extra-file=/dev/stdin" \
                ${OPT_SOCK:+-S"${OPT_SOCK}"} \
                ${VAL_MASTER:+"--master-data=2"} \
                ${VAL_SLAVE:+"--dump-slave=2"} \
                --max-allowed-packet=1G \
                --set-gtid-purged=OFF --force \
                ${VAL_TRANSACTION:+"--single-transaction"} \
                ${VAL_LOCKBACKUP:+"--lock-for-backup"} \
                --events --routines --triggers \
                --hex-blob --log-error="${error_log}" \
                ${VAL_ALLDB:+"--all-databases"} \
                ${VAL_DATABASE:+"--databases"} \
                ${VAL_DATABASE:+"${DB_NAME}"} \
                ${VAL_TABLES:+"--tables"} \
                ${VAL_TABLES:+"${TB_NAME}"} > "${DSTFILE}"

  if [[ "$?" -ne 0 || -s "${error_log}" ]]; then
    [[ -e "${error_log}" ]] && warn "backup error: ${error_log}"
    return 1 # backup error
  fi

  log "backup ok - $DSTFILE"
  [[ -e "${error_log}" ]] && unlink "${error_log}"
  return 0
}

mysql_is_alive() {
  if mysql_exec_by_cnf 'SELECT 1 LIMIT 1' >/dev/null; then
    return 0
  else
    warn "${OPT_HOST}:${OPT_PORT} is not alive"
    return 1
  fi
}

_mysql_slave_check() {
  mysql_exec_by_cnf "SHOW SLAVE STATUS\G" | \
    perl -ne '
      $status{master_host} = $1 if m/Master_Host: (.+)$/i;
      $status{master_port} = $1 if m/Master_Port: (\d+)$/i;
      $status{io_running}  = $1 if m/Slave_IO_Running: (\w+)$/i;
      $status{sql_running} = $1 if m/Slave_SQL_Running: (\w+)$/i;
      $status{behind_delay}= $1 if m/Seconds_Behind_Master: (\d+)$/i;
      $status{last_sql_errno} = $1 if m/Last_SQL_Errno: (\d+)$/i;

      END {
        if (! defined $status{master_host}) {
          print "9"; # is master
        }
        else {
          if ($status{io_running} =~ /Yes/
               && $status{sql_running} =~ /Yes/) {
             if ($status{behind_delay} < 120) {
               print "0"; # slave is ok
             }
             else {
               if ($status{last_sql_error} == 0) {
                 print "1"; # slave delay
               }
               else {
                 print "3"; # sql thread errors
               }
             }
          }
          else {
             print "4"; # slave is error
          }
        }
      }
    ';
}

mysql_is_slave() {
  RES=$(_mysql_slave_check)
  if (( ${RES} < 3 )); then
    return 0  # is slave
  else
    return 1  # may be master
  fi
}

mysql_is_db_exist() {
  local DB_NAME="$1"
  if [[ -z "${DB_NAME}" ]]; then
    warn "DB_NAME is not set"
    return 1 # must set db
  fi

  NAME=$(mysql_exec_by_cnf "
          SELECT SCHEMA_NAME
          FROM information_schema.SCHEMATA
          WHERE SCHEMA_NAME = \"${DB_NAME}\"
        ")
  NAME="${NAME:-""}"

  if [[ "${DB_NAME}" == "${NAME}" ]]; then
    return 0 # exists
  else
    return 1 # not exists
  fi
}

mysql_is_table_exist() {
  local DB_NAME="$1"
  local TB_NAME="$2"

  if [[ -z "${DB_NAME}" || -z "${TB_NAME}" ]]; then
    warn "DB_NAME or TB_NAME is not set"
    return 1 # must set db and table
  fi

  NAME=$(mysql_exec_by_cnf "
          SELECT TABLE_NAME
          FROM information_schema.TABLES
          WHERE TABLE_SCHEMA = \"${DB_NAME}\"
              AND TABLE_NAME = \"$TB_NAME\"
        ")
  NAME="${NAME:-""}"

  if [[ "${TB_NAME}" == "${NAME}" ]]; then
    return 0 # exists
  else
    return 1 # not exists
  fi
}

mysql_is_all_innodb() {
  # return true if all table is innodb or tokudb
  local res=$(mysql_exec_by_cnf "
              SELECT table_name AS tblist
              FROM information_schema.TABLES 
              WHERE ENGINE NOT IN (\"TokuDB\", \"InnoDB\")
              AND TABLE_SCHEMA NOT IN(\"mysql\", \"test\", 
              \"information_schema\", \"performance_schema\", \"sys\")
              LIMIT 1
            ")

  # all table is innodb/tokudb
  [[ -z "$res" ]] && return 0

  return 1
}

# return negative number when db and table are not set or not exists
mysql_get_table_rows() {
  local DB_NAME="$1"
  local TB_NAME="$2"

  if [[ -z "${DB_NAME}" || -z "${TB_NAME}" ]]; then
    warn "DB_NAME or TB_NAME is not set"
    printf '%d\n' -1  # must set db and table
    return 1
  fi

  if ! $(mysql_is_table_exist "${DB_NAME}" "${TB_NAME}"); then
    warn "${DB_NAME}.${TB_NAME} is not exists"
    printf '%d\n' -2
    return 2
  fi

  ROWS=$(mysql_exec_by_cnf "
         SELECT COUNT(*) as ROWS 
         FROM ${DB_NAME}.${TB_NAME}
         WHERE 1 = 1
       ")
  ROWS="${ROWS:-0}"

  printf '%d\n' $ROWS
}

mysql_get_variables() {
  local var="$1"
  local val=$(mysql_exec_by_cnf "
              SHOW GLOBAL VARIABLES 
              WHERE Variable_name = \"${var}\"
             " | \
              cut -f 2
             )

  printf '%s\n' "${val:-""}"
}

mysql_get_version() {
  local version=$(mysql_exec_by_cnf "
                  SELECT SUBSTRING(VERSION(), 1, 3) LIMIT 1
                ")

  [[ -z "$version" ]] && version="5.5"
  printf '%s\n' "${version}"
}

