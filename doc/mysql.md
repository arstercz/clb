## mysql

The `mysql` libary contains some `common method`, custom scripts shoule be set the following variables before invoke method:
```
OPT_DEFT
OPT_HOST      # default is 127.0.0.1
OPT_PORT      # default is 3306
OPT_USER      # default is root
OPT_PASS
OPT_CHARSET   # default is utf8mb4
```

such as the following example:
```
#!/bin/bash


OPT_HOST="10.1.1.10"
OPT_PORT=3306
OPT_USER="root"
OPT_PASS="xxxxxxxx"

. /etc/clb/lib/log
. /etc/clb/lib/mysql

if mysql_is_slave; then
  log "$OPT_HOST:$OPT_PORT is slave"
else
  echo "is not slave"
fi

if mysql_is_all_innodb; then
  echo "is all innodb"
fi

if mysqldump_backup "percona" "users"; then
  log "backup percona ok"
else
  warn "backup percona error"
fi

```

The function list:

* [mysql_exec](#mysql_exec)
* [mysql_exec_by_cnf](#mysql_exec_by_cnf)
* [mysqldump_backup](#mysqldump_backup)
* [mysql_is_slave](#mysql_is_slave)
* [mysql_is_db_exist](#mysql_is_db_exist)
* [mysql_is_table_exist](#mysql_is_table_exist)
* [mysql_is_all_innodb](#mysql_is_all_innodb)
* [mysql_get_table_rows](#mysql_get_table_rows)
* [mysql_get_variables](#mysql_get_variables)
* [mysql_get_version](#mysql_get_version)

### mysql_exec

How to use: `mysql_exec "SELECT ..."`, other user can see the password if running some query, read more from [use-mysql-shell-securely-from-bash](https://blog.arstercz.com/%e5%a6%82%e4%bd%95%e5%ae%89%e5%85%a8%e7%9a%84%e4%bd%bf%e7%94%a8-bash-%e6%93%8d%e4%bd%9c-mysql/)

#### mysql_exec_by_cnf

The same as `mysql_exec` method, but cann't see the password.

### mysqldump_backup

How to use: `mysqldump_backup db table`

`db` and `table` are optional, `mysqldump_backup` will backup all instance if not set the `db` and `table`; will backup the `db` database if you set `db` option, and will backup `db.table` if you set both `db` and `table`.

`mysqldump_backup` will add different option depend on the instance role:

| option | condition |
| :-: | :-: |
| --master-data | if mysql is master |
| --dump-slave | if mysql is slave |
| --lock-for-backup | if mysql version is greater than 5.5 |
| --single-transaction | if all of the mysql table use innodb or tokudb |

### mysql_is_slave

How to use: `mysql_is_slave`, determine the mysql is whether slave or not.

### mysql_is_db_exist

How to use: `mysql_is_db_exist db`, determine the database is whether in this MySQL instance or not.

### mysql_is_table_exist

How to use: `mysql_is_table_exist db table`, determine the table `db.table` is whether in this MySQL instance or not.

### mysql_is_all_innodb

How to use: `mysql_is_all_innodb`, determine the tables in this MySQL are both use `InnoDB` or `TokuDB` engine.

### mysql_get_table_rows

How to use: `mysql_get_table_rows db table`, return negative number if `db` or `table` are not in this MySQL.

*RISK*: this will running slowly and have a negative impact if table is big.

### mysql_get_variables

How to use: `mysql_get_variables "innodb_buffer_pool_size"`, get the variables value, does not support regexp.

### mysql_get_version

How to use: `mysql_get_version`, get the MySQL version, such as `5.6, 5.7`.
