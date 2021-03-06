# send by mail command

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/log.sh"
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"

NOTIFY_BY_EMAIL=1
SMTP_EMAIL="${SMTP:-"127.0.0.1"}"
FROM_EMAIL="${FROM_EMAIL:-"report@example.com"}"
RECV_EMAIL="${RECEIVER_EMAIL:-"user1@example.com"}"
MSGS_EMAIL="${MSG_EMAIL:-"mail report"}"
TITIE_EMAIL="${TITLE_EMAIL:-"mail report on $(hostname)"}"


# mail_report msg...
mail_report() {
  MAIL_CMD=$(_which mail)
  [ ! -x "${MAIL_CMD}" ] && return 1

  if [[ "${NOTIFY_BY_EMAIL}" -eq 1 ]]; then
    printf '%s\n' "${MSGS_EMAIL}" \
      | mail -r "${FROM_EMAIL}" -S smtp="${SMTP_EMAIL}" -s "${TITLE_EMAIL}" \
        "$RECV_EMAIL"

     [[ "$?" -eq 0 ]] && return 0 || warn "send with ${SMTP_EMAIL} error!"
  fi

  return 1
}
