## lock

The `lock` library wrap the `flock` ensure that only run once(the same parameters) at the same time:

* [lock_is_ok](#lock_is_ok)
* [lock_exit](#lock_exit)

first of all, this library will save the `$0 $@` to the array variable `WT_PARAMS` so that we can generate default lock file, and all of the above function use the global variable: `WT_LOCKFILE`, you can set `WT_LOCKFILE` a specified file as you want. default is:
```
${WT_WORK_TEMP}/$(short_md5)~$(whoami).lock-run
```

### lock_is_ok

try to get a lock, the same as the following command:
```
flock -w 1 -x -n fd
```

### lock_exit

delete the `WT_LOCKFILE` if file exists.

## How to use?

a basic example:
```
#!/bin/sh

. /etc/clb/lib/log
. /etc/clb/lib/lock

# optional set the WT_LOCKFILE
WT_LOCKFILE="/tmp/lock-test.lock" 

trap 'lock_exit' INT TERM EXIT

if ! lock_is_ok; then
  error "only run once at the same time"
fi

# do the operations that may take time, such as

sleep "$1"
```
