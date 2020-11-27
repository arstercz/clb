# log functions

# wheter disable log or not
WT_SILENT=""

ts() {
  local script_name="$(basename "${0}")"
  TS=$(date +%F-%T | tr ':-' '_')
  [[ "$WT_SILENT" ]] || echo "$TS [${script_name}] - $*"
}

log() {
  ts "[info] $*"
}

warn() {
  ts "[warn] $*" >&2
}

error() {
  ts "[error] $*" >&2
  exit 1
}

die() {
  ts "[fatal] $*" >&2
  exit 2
}
