## rsync

* [clb_rsync_ssh](#clb_rsync_ssh)
* [clb_rsync_deamon](#clb_rsync_daemon)

The `rsync` library wrap the `rsync` and add the following option:
```
-a
-z
-v
--bwlimit
--timeout
--contimeout # only daemon mode
```

both `clb_rsync_ssh` and `clb_rsync_deamon` support additional options

### clb_rsync_ssh

How to use: `clb_rsync_ssh [rsync option] src dest`, eg:
```
. /etc/clb/lib/rsync

WT_RSYNC_SSHPORT=22
clb_rsync_ssh --progress $src $remote_host:$dest
clb_rsync_ssh -n $src $remote_host:$dest          # rsync dry-run
```



### clb_rsync_daemon

How to use: `clb_rsync_deamon [rsync option] src dest`, eg:
```
. /etc/clb/lib/rsync

RSYNC_PASSWORD='password' # rsync user's password
clb_rsync_deamon --progress $src rsync-user@host::module
clb_rsync_deamon -n $src rsync-user@host::module   # rsync dry-run
```


