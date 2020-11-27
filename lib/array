# common use for array

# usage: array_del_dups k1 k2 k2 k3 ...
array_del_dups() {
  declare -A tmp_arrs

  for i in "$@"; do
    [[ "$i" ]] || continue
    IFS=" "
    tmp_arrs["${i:- }"]=1
  done

  echo "${!tmp_arrs[@]}"
}

# usage: array_is_contains item k1 k2 k3 ...
array_is_contains() {
  local list="$1"
  shift
  declare -r -a array=("$@")

  local item
  for item in "${array[@]}"; do
    [[ "$item" == "$list" ]] && return 0
  done

  return 1
}

# usage: array_join delimeter k1 k2 k3 ...
array_join() {
  local delimeter="$1"
  shift
  declare -r -a array=("$@")

  if [[ ${#array[@]} -eq 0 ]]; then
    echo -n ""
    return 1
  fi

  local res=""
  for (( i=0; i<"${#array[@]}"; i++)); do
    if (( "$i" > 0 )); then
      res="${res}${delimeter}"
    fi
    res="${res}${array[i]}"
  done

  printf '%s\n' "$res"
}
