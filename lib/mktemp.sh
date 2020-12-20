# common use for make temp directory

# make or delete temp directory
WT_TMPDIR=""

mk_tempdir() {
  local dir="${1:-""}"

  if [ -n "$dir" ]; then
    if [ ! -d "$dir" ]; then
       mkdir "$dir" || die "Cannot make tmpdir $dir"
    fi
    WT_TMPDIR="$dir"
  else
    local pid="$$"
    WT_TMPDIR=`mktemp -d -t "/tmp/${pid}.WT_XXXX"` \
       || die "Cannot make secure tmpdir"
  fi
}

rm_tempdir() {
  if [ -n "$WT_TMPDIR" ] && [ -d "$WT_TMPDIR" ]; then
    rm -rf "$WT_TMPDIR"
  fi
  WT_TMPDIR=""
}
