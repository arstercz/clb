## log

The `log` libary contains some log funtions:

* [log](#log)
* [warn](#warn)
* [error](#error)
* [die](#die)

**note**: you can disable all log ouput by set the value of the `WT_SILENT` variables.

### log

How to use: `log "message"`

Print the `info` messages:
```
log "rsync backup ok"
```
the result format is:
```
2020_11_27_11_27_23 [rsync_backup.sh] - [info] rsync backup ok
```

### warn

How to use: `warn "message"`

Print the `warn` messages:
```
warn "rsync backup error"
```
the result format is:
```
2020_11_27_11_29_23 [rsync_backup.sh] - [warn] rsync backup error
```

### error, die

How to use:
```
error "message"  # return code: 1, prompt [error]
die "message"    # return code: 2, prompt [fatal]
```

both `error` and `die` print error messages, and exit the script, but the return code and prompt is different. it's best not to break the message line:
```
error "check error"
die "check error"
```

the result format is
```
2020_11_27_11_31_30 [check.sh] - [error] check error
2020_11_27_11_31_30 [check.sh] - [fatal] check error
```

