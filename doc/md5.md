## md5

The `md5` library can get and check the md5sum, contains the following functions:

* [md5_args](#md5_args)
* [md5_file](#md5_file)
* [md5_check](#md5_check)

### md5_args

How to use: `md5_args var1 var2...`

`md5_args` can be used with the command line or variable value, such as:
```
sum=$(md5_args "string1" "string2")
```

the above usage is the same as get the string `string1 string2` md5 sum:
```
9749b6f8c4fe72ba1e0d434c79bd850f
```

### md5_file

How to use: `md5_file file`

`md5_file` get the file's md5 sum:
```
sum=$(md5_file "file")
```

if the `file` contains `string1 string2`, the md5 sum is:
```
9749b6f8c4fe72ba1e0d434c79bd850f
```

### md5_check

How to use: `md5_check md5_check_file is_print_log`

`md5_check` wrap the `md5sum -c ...` to verify the files md5 sum, the `md5_check_file's` content should be satisfy the output format of the `md5sum file`:
```
# cat md5_check_file
af401d47d6c4fcb7cfe827004747ad39  array.sh
9e78265956ae05159e86acf34ae6e3c1  lock.sh
5c1ef8497cc9ef8dea79913dc9b4c9eb  mysql.sh
aefc86604986eca88fad4fa1a6551fb7  port-open.sh
f75c9860e2c07c5f0cef86409c799c60  ssh.sh
```

then you can check the md5 sum:
```
if md5_check md5_check_file; then
  log "md5 check ok"
else
  warn "md5 check error"
fi
```
`md5_check` is also support print failuer log when check fail:
```
if md5_check md5_check_file "yes"; then
  log "md5 check ok"
else
  # failuer message automatic print
  ...
fi
```

the output of the `md5_check` will be save in directory `${WT_WORK_LOGS/}`.
