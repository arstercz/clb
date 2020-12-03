## ssh

* [clb_ssh](#clb_ssh)
* [clb_scp](#clb_scp)

The `ssh` library wrap the `ssh` and `scp` command, and add the following option:
```
ServerAliveInterval=60
ServerAliveCountMax=10
StrictHostKeyChecking=no
PasswordAuthentication=no
BatchMode=yes
ConnectTimeout=5
```

### clb_ssh

How to use: `clb_ssh host command`

### clb_scp

How to use: `clb_scp ... host:...`
