## basic examples

some examples which use `clb` library:

* [clb-lockrun](#clb-lockrun)
* [clb-logtail](#clb-logtail)
* [clb-mysql-empty-user-ops](#clb-mysql-empty-user-ops)
* [clb-redis-backup](#clb-redis-backup)

### clb-lockrun

bash script or command can only run once at any time by using flock.

#### Usage:
```
1. run command in session A
$ clb-lockrun sleep 20

2. run command in session B
$ clb-lockrun sleep 20
2020_12_10_13_39_23 [clb-lockrun] - [error] only once can run at one time - sleep 20
```

use `-h` option for more usage.

### clb-logtail

read the log file from last checkpoint, it's useful when analsis log file with a incrementally way.

#### Usage:
```
$ echo 1 >/tmp/t.log
$ clb-logtail -f /tmp/t.log 
1
$ echo 2 >>/tmp/t.log        
$ clb-logtail -f /tmp/t.log 
2
```

use `-h` option for more usage.

### clb-mysql-empty-user-ops

the mysql empty user maybe unsafe, this tool support change or remove mysql empty user.

#### Usage:
```
bash ops_mysql-empty-pass -l
2020_12_09_19_22_04 [info] user list for empty password:
  [5.7] - 'empty_test'@'::1'
  [5.7] - 'empty_test'@'10.1.2.%'

bash ops_mysql-empty-pass -t 2
2020_12_09_19_34_13 [info] drop for 'empty_test'@'::1' ok!
2020_12_09_19_34_13 [info] drop for 'empty_test'@'10.1.2.%' ok!
```

use `-h` option for more usage.

### clb-redis-backup

backup the redis's  rdb and aof file.

#### Usage:
```
bash clb-redis-backup -H 10.12.17.25 -p 6379
2020_12_30_17_18_45 [clb-redis-backup] - [info] /opt/redis6.0/data/dump_6379.rdb
receiving incremental file list
dump_6379.rdb

sent 30 bytes  received 624 bytes  1308.00 bytes/sec
total size is 36731  speedup is 56.16
2020_12_30_17_18_45 [clb-redis-backup] - [info] backup rdb /opt/redis6.0/data/dump_6379.rdb ok
receiving incremental file list
appendonly.aof

sent 30 bytes  received 202943 bytes  405946.00 bytes/sec
total size is 37503456  speedup is 184.77
```
