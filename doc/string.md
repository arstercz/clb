## string

The `string` library contains some string functions:

* [string_trim_space](#string_trim_space)
* [string_trim_quotes](#string_trim_quotes)
* [string_lstrip](#string_lstrip)
* [string_rstrip](#string_rstrip)
* [is_string_contains](#is_string_contains)
* [is_string_empty_null](#is_string_empty_null)
* [string_to_lower](#string_to_lower)
* [string_to_upper](#string_to_upper)
* [string_split](#string_split)

### string_trim_space

remove the leading and trailling spaces(include tab) of:
```
str=$(string_trim_space "  hello,  world  	")

echo $str  # hello, world
```

### string_trim_quotes

remove the quote(single or dubble):
```
str=$(string_trim_quotes "hello,' \"world\"")

echo $str   # hello, world
```

### string_lstrip

remove the left greed match substring: 
```
str=$(string_lstrip "hello, world, hello, world" "*el")

echo $str   # lo, world
```

### string_rstrip

the same as `string_lstrip`, but from right:

```
str=$(string_rstrip "hello, world, hello, world" "*el")

echo $str   # h
```

### is_string_contains

determine the string whether contains substring or not:

```
if is_string_contains "hello, world" "wor"; then
  log "contains"
else
  warn "not contains"
fi
```

### is_string_empty_null

determine the string is `'null'` or `null character string`: 
```
if is_string_empty_null "$string"; then
  log "yes"
else
  warn "no"
fi
```

### string_to_lower

convert to lower case:
```
string_to_lower "HelLo"    # hello
```

### string_to_upper

convert to upper case:
```
string_to_upper "HelLo"    # HELLO
```

### string_split

How to use: `string_split string delimeter`, split string into array:
```
for x in $(string_split "1,2,3,4" ","); do
  echo "$x"
done
```

get the result:
```
1
2
3
4
```

