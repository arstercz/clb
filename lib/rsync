# common use for rsync

# rsync password, default is empty
RSYNC_PASSWORD="${RSYNC_PASSWORD}:-"""

WT_RSYNC_SSHPORT="${WT_RSYNC_SSHPORT:-"22"}"
# resource limit
WT_RSYNC_DEL="${WT_RSYNC_DEL:-"1"}"       # use rsync --delete
WT_RSYNC_LIMIT="${WT_RSYNC_LIMIT:-30000}" # bandwidth limit
WT_RSYNC_TMOUT=10                         # I/O timeout
WT_RSYNC_CMOUT=8                          # conn timeout

# send by ssh connection
clb_rsync_ssh() {
  [ "$WT_RSYNC_DEL" ] && DELRUN="--delete"

  rsync -azv $DELRUN -e "ssh -p ${WT_RSYNC_SSHPORT}" \
        --bwlimit=${WT_RSYNC_LIMIT} --timeout=$WT_RSYNC_CMOUT \
        "$@"
}

# send to rsync deamon
clb_rsync_deamon() {
  [ "$WT_RSYNC_DEL" ] && DELRUN="--delete"
  [ "$RSYNC_PASSWORD" ] && export RSYNC_PASSWORD

  rsync -azv $DELRUN --bwlimit=${WT_RSYNC_LIMIT} \
        --timeout=$WT_RSYNC_TMOUT --contimeout=$WT_RSYNC_CMOUT \
        "$@"
}
