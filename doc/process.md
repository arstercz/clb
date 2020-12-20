## process

The `process` library contains the following method to get process info:

* [_lsof](#_lsof)
* [_pidof](#_pidof)
* [_pidofpattern](#_pidofpattern)
* [_userofpid](#_userofpid)
* [_is_pid_run](#_is_pid_run)
* [_pidport](#_pidport)
* [_portpid](#_portpid)
* [get_pid_stat](#get_pid_stat)
* [is_host_port_open](#is_host_port_open)

### _lsof

How to use: `_lsof pid`, get the pid's open file.

### _pidof

How to use: `_pidof pid`, get the process name of the pid.

### _pidofpattern

How to use: `_pidofpattern pattern`, get the pid of the matched process.

### _userofpid

How to use: `_userofpid pid`, get the pid's user info.

### _is_pid_run

How to use: `_is_pid_run pid`, determine the pid is whether running or not.

### _pidport

How to use: `_pidport pid`, get the port of the pid.

### _portpid

How to use: `_portpid port`, get the pid of the port.

### get_pid_stat

How to use: `get_pid_stat pid`, get the status of the pid. such as:
```
. /etc/clb/lib/process.sh
pid="$1"

declare -A pidstats="$(get_pid_stat $pid)"

for x in "${!pidstats[@]}"; do
  echo "-- $x : ${pidstats[$x]}"
done
```

the output include the following items if the pid is running:
```
-- time : 9857     # running in minutes
-- share : 7.69M   # share memory of the pid
-- virt : 9.49G    # virtual memory of the pid
-- user : mysql    # user of the pid
-- res : 7.09G     # resident memory of the pid
-- mem : 11.3%     # memory utilization of the pid
-- pid : 4204      # pid number
-- cmd : mysqld    # command of the pid
-- cpu : 0.0%      # cpu utilization of the pid
```

**note**: most of the items are the same as `top -p pid`.

### is_host_port_open

How to use: `is_host_port_open host port`, test the `host:port` is whether open or not.
