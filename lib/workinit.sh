# common dirs initial

# work dir
WT_WORK_BASE="${WT_WORK_BASE:-"/tmp/clb-work"}"
WT_WORK_DATA="${WT_WORKDIR:-"${WT_WORK_BASE}/data"}"
WT_WORK_TEMP="${WT_WORKDIR:-"${WT_WORK_BASE}/temp"}"
WT_WORK_CONF="${WT_WORKDIR:-"${WT_WORK_BASE}/conf"}"
WT_WORK_LOGS="${WT_LOGSDIR:-"${WT_WORK_BASE}/logs"}"

# initial dirs

for dir in ${!WT_WORK*}; do
  [[ "$(dirname ${!dir})" == "/" ]] && {
    echo "[error] work dir can not in root directory!"
    exit 1
  }

  [[ -d "${!dir}" ]] || mkdir -m 0777 -p "${!dir}"
done
