# common use for string

# usage: string_trim_space "  string "
string_trim_space() {
  : "${1#"${1%%[![:space:]]*}"}"
  : "${_%"${_##*[![:space:]]}"}"
  printf '%s\n' "$_"
}

# usage: string_trim_quptes "string"
string_trim_quotes() {
  : "${1//\'}"
  printf '%s\n' "${_//\"}"
}

# usage: string_lstrip "string" "pattern"
string_lstrip() {
  printf '%s\n' "${1##$2}"
}

# usage: string_rstrip "string" "pattern"
string_rstrip() {
  printf '%s\n' "${1%%$2}"
}

# usage: is_string_regex "string" "regex"
is_string_regex() {
  [[ $1 =~ $2 ]]
}

# usage: is_string_contains "string" "substring"
is_string_contains() {
  echo "$1" | grep -q "$2"
}

# usage: is_string_empty_null "string"
is_string_empty_null() {
  local str="$1"
  [[ -z "$str" || "$str" == "null" ]]
}

# usage: string_to_lower "string"
string_to_lower() {
  printf '%s\n' "${1,,}"
}

# usage: string_to_upper "string"
string_to_upper() {
  printf '%s' "${1^^}"
}

# usage: string_split "string" "delimeter"
# default delimeter is space
string_split() {
  IFS=$'\n'
  local str="$1"
  local deli="${2:-" "}"

  read -d "" -ra arrs <<< "${str//$deli/$'\n'}"
  echo "${arrs[@]}"
}
