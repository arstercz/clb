## email

The `email` library can be used to send email, this wrap the `mail` command, it does not support user and password, custom bash script should change the following variables:
```
SMTP_EMAIL   # default is 127.0.0.1, you can change to internal ip address which can send email by mail command
RECV_EMAIL   # email recevier, such as "user1@email.com,user2@email...."
MSGS_EMAIL   # email message
TITLE_EMAIL  # email title
```

### How to use? such as the example:

```
#!/bin/bash

set -e

. /etc/clb/lib/email

SMTP_EMAIL="10.1.1.10"
FROM_EMAIL="report@example.com"
RECV_EMAIL="xxxx1@example.com,xxxx2@example.com"
TITLE_EMAIL="test report on $(hostname)"

MSGS_EMAIL=$(cat <<'WTDOC'
# uptime
12:41:07 up 351 days, 15:57,  4 users,  load average: 0.04, 0.08, 0.11

# free -m
              total        used        free      shared  buff/cache   available
Mem:          64216       11150       12695        3224       40370       48872
Swap:         45775        1238       44537
WTDOC
)

if mail_report; then
  log "send ok"
else
  warn "send error"
fi
```
