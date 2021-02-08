## mongodb

The `mongodb` libary contains some `common method`, custom scripts shoule be set the following variables before invoke method:
```
OPT_HOST      # default is 127.0.0.1
OPT_PORT      # default is 27017
OPT_USER      # optional
OPT_PASS      # optional
OPT_AUTHDB    # optional, response to mongo option --authenticationDatabase
```

such as the following example:
```
#!/bin/bash

OPT_HOST="10.1.1.10"
OPT_PORT=27017
OPT_USER="root"      # optional
OPT_PASS="xxxxxxxx"  # optional
OPT_AUTHDB="admin"   # optional

. /etc/clb/lib/log.sh
. /etc/clb/lib/mongodb.sh

if mongo_is_alive; then
  log "$OPT_HOST:$OPT_PORT is alive"
else
  error "$OPT_HOST:$OPT_PORT is not running"
fi

if mongo_is_repl; then
  log "$OPT_HOST:$OPT_PORT is slave or secondary"
  if mongo_is_repl_ok; then
    log "repl is ok"
  else
    warn "repl status is error"
  fi
else
  warn "is not repl"
fi

if mongo_backup sbtest1; then
  log "backup ok"
else
  warn "backup error"
fi
```

The function list:

* [mongo_exec](#mongo_exec)
* [mongo_is_alive](#mongo_is_alive)
* [mongo_is_replset](#mongo_is_replset)
* [mongo_role_name](#mongo_role_name)
* [mongo_get_repl_lag](#mongo_get_repl_lag)
* [mongo_is_repl](#mongo_is_repl)
* [mongo_is_repl_ok](#mongo_is_repl_ok)
* [mongo_is_slave](#mongo_is_slave)
* [mongo_is_slave_ok](#mongo_is_slave_ok)
* [mongo_is_secondary](#mongo_is_secondary)
* [mongo_is_secondary_ok](#mongo_is_secondary)
* [mongo_has_long_running](#mongo_has_long_running)
* [mongo_has_lock](#mongo_has_lock)
* [mongo_backup](#mongo_backup)

### mongo_exec

How to use: `mongo_exec "db.coll1.find..."`;

### mongo_is_alive

How to use: `mongo_is_alive`, determine the mongo is whether alive or not.

### mongo_is_replset

How to use: `mongo_is_replset`, determine the mongo is whether a member of replica set;

### mongo_role_name

How to use: `role=$(mongo_role_name)`, get the role name of the mongo, it maybe `master, slave, primary, secondary, arbiter`;

### mongo_get_repl_lag

How to use: `lag=$(mongo_get_repl_lag)`, get the replica lag of slave or secondary.

### mongo_is_repl

How to use: `mongo_is_repl`, determine the mongo is whether `slave/secondary` or not;

### mongo_is_repl_ok

How to use: `mongo_is_repl_ok threshold`, determine the replica lag is ok or not, the default `threshold` is `150` seconds. such as:
```
if mongo_is_repl_ok 300; then
  log "this mongo's repl status is ok"
else
  error "......"
fi
```

### mongo_is_slave

How to use: `mongo_is_slave`, determine the mongo is whether slave or not.

### mongo_is_slave_ok

How to use: `mongo_is_slave_ok threshold`, determine the slave replica lag is ok or not, the default `threshold` is `150` seconds.

### mongo_is_secondary

How to use: `mongo_is_secondary`, determine the mongo is whether secondary or not.

### mongo_is_secondary_ok

How to use: `mongo_is_secondary_ok threshold`, determine the secondary replica lag is ok or not, the default `threshold` is `150` seconds.

### mongo_has_long_running

How to use: `mongo_has_long_running threshold`, determine the mongo whether have long time running queries or not, the default `threshold` is `10` seconds, return true if long time queries number greater than `3`:
```
if mongo_has_long_running 20; then
  warn "have long time running quries"
fi
```

### mongo_has_lock

How to use: `mongo_has_lock threshold`, determine the mongo whether have queries that in `waiting for lock` state, default threshold is `3`, return true if greater than `threshold` queries in `waiting for lock` state;

### mongo_backup

How to use: `mongo_backup db collection`, backup the mongo, `db` and `collection` is optional, the following syntax is ok:
```
mongo_backup
mongo_backup dbname
mongo_backup dbname collction1
```
