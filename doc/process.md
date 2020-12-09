## process

The `process` library contains the following method to get process info:

* [_lsof](#_lsof)
* [_pidof](#_pidof)
* [_pidofpattern](#_pidofpattern)
* [_userofpid](#_userofpid)
* [_is_pid_run](#_is_pid_run)
* [_pidport](#_pidport)
* [_portpid](#_portpid)
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

### is_host_port_open

How to use: `is_host_port_open host port`, test the `host:port` is whether open or not.
