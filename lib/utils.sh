# Common shell functions

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/log.sh"

# utils funtion
_seq() {
  local i="$1"
  awk "BEGIN { for(i=1; i<=$i; i++) print i; }"
}

_which() {
  if [ -x /usr/bin/which ]; then
    /usr/bin/which "$1" 2>/dev/null | awk '{print $1}'
  elif which which 1>/dev/null 2>&1; then
    which "$1" 2>/dev/null | awk '{print $1}'
  else
    echo "$1"
  fi
}

# check current user whether is root/sudo or not
is_root() {
  [[ "$EUID" -eq 0 ]]
}

size_to_bytes() {
  local size="$1"
  echo $size | perl -ne '
    %f=(
         B => 1, 
         K => 1_024, 
         M => 1_048_576, 
         G => 1_073_741_824, 
         T => 1_099_511_627_776
       );
    m/^(\d+)([kMGT])?/i; 
    print $1 * $f{uc($2 || "B")};
  '
}

# print 1  if f1 >  f2
# print 0  if f1 == f2
# print -1 if f1 <  f2
float_compare() {
  awk -v f1="$1" -v f2="$2" 'BEGIN { printf "%d", (f1 > f2) ? 1 : (f1 == f2) ? 0 : -1 }'
}
