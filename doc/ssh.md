## ssh

* [ssh](#ssh)
* [scp](#scp)

The `ssh` library wrap the `ssh` and `scp` command, and add the following option:
```
ServerAliveInterval=60
ServerAliveCountMax=10
StrictHostKeyChecking=no
PasswordAuthentication=no
BatchMode=yes
ConnectTimeout=5
```

### ssh

How to use: `clb_ssh host command`

### scp

How to use: `clb_scp ... host:...`
