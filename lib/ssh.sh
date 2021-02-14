# ssh/scp common option

WT_SSHPORT="${WT_SSHPORT:-"22"}"

clb_ssh() {
  ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=10 \
      -o StrictHostKeyChecking=no -o PasswordAuthentication=no \
      -o BatchMode=yes -o ConnectTimeout=5 \
      -p ${WT_SSHPORT} "$@"
}

clb_scp() {
  scp -o ServerAliveInterval=60 -o ServerAliveCountMax=10 \
      -o StrictHostKeyChecking=no -o PasswordAuthentication=no \
      -o BatchMode=yes -o ConnectTimeout=5 \
      -P ${WT_SSHPORT} "$@"
}
