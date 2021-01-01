## redis

The `redis` libary contains some `common method`, custom scripts shoule be set the following variables before invoke method:
```
OPT_HOST      # default is 127.0.0.1
OPT_PORT      # default is 6379
OPT_PASS
```

**note**: we'll cache redis info result for 60 seconds to avoid connect redis frequently.

such as the following example, read more example from `examples/clb-redis-backup`:
```
#!/bin/bash

. /etc/clb/lib/log.sh
. /etc/clb/lib/redis.sh

OPT_HOST="10.1.1.10"
OPT_PORT=6379
OPT_PASS="xxxxxxxx"

# some command maybe renamed
CMD_CONFIG="config"


if ! redis_is_ok; then
  error "redis is not ok"
fi

if redis_is_slave; then
  log "redis is slave"
fi

redis_trigger_bgsave
```

The function list:

* [redis_exec](#redis_exec)
* [redis_is_ok](#redis_is_ok)
* [redis_item_get](#redis_item_get)
* [redis_is_slave](#redis_is_slave)
* [redis_is_slave_ok](#redis_is_slave_ok)
* [redis_is_cluster](#redis_is_cluster)
* [redis_is_cluster_ok](#redis_is_cluster_ok)
* [redis_is_in_loading](#redis_is_in_loading)
* [redis_is_in_bgsave](#redis_is_in_bgsave)
* [redis_trigger_bgsave](#redis_trigger_bgsave)
* [redis_is_aof_enable](#redis_is_aof_enable)
* [redis_is_aof_in_rewrite](#redis_is_aof_in_rewrite)
* [redis_trigger_aofrewrite](#redis_trigger_aofrewrite)
* [redis_is_memory_ok](#redis_is_memory_ok)
* [redis_get_rdbfile](#redis_get_rdbfile)
* [redis_get_aoffile](#redis_get_aoffile)

### redis_exec

run redis command. such as:
```
redis_exec "info all"
```

### redis_is_ok

check whether the redis is ok or not, such as:
```
if redis_is_ok; then
  log "redis is ok"
else
  error "redis is error"
fi
```

### redis_item_get

get the item from `redis info`, such as:
```
role=$(redis_item_get "role")
```

### redis_is_slave

check whether the redis is slave or master.

### redis_is_slave_ok

check whether the redis slave is ok or not.

### redis_is_cluster

check whether the redis is cluster or not.

### redis_is_cluster_ok

check whether the redis cluster is ok or not.

### redis_is_in_loading

check whether the redis is in loading.

### redis_is_in_bgsave

check whether the redis is in bgsave.

### redis_trigger_bgsave

trigger `bgsave` command if last save file is too old. such as:
```
# trigger bgsave if last bgsave file was saved 7200 seconds ago
redis_trigger_bgsave 7200
```

### redis_is_aof_enable

check whether the redis enable aof or not.

### redis_is_aof_in_rewrite

check whether the redis is in aof rewrite or not.

### redis_trigger_aofrewrite

trigger `bgrewriteaof` command if the redis is not in `rewrite`.

### redis_is_memory_ok

check redis memory used is ok or not, such as:
```
if redis_is_memory_ok 90; then
  log "redis memory used less than 90%"
fi
```

### redis_get_rdbfile

get rdb file path name.

### redis_get_aoffile

get aof file path name.
