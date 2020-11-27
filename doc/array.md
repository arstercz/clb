## array

The `array` library contains some array functions:

* [array_del_dups](#array_del_dups)
* [array_is_contains](#array_is_contains)
* [array_join](#array_join)

### array_del_dups

How to use: `array_del_dups array`

Remove the array's duplication items, such as
```
names=(1 2 2 3 5 5)

dup_name=$(array_del_dups ${names[@]})
```
the result is:
```
echo $dup_name[@]   # 1 2 3 5
```

### array_is_contains

How to use: `array_is_contains item array`

Determines if the item is in an array or not, such as:
```
names=(1 2 2 3 5 5)

if array_is_contains 3 ${names[@]}; then
  log "3 is in names"
else
  warn "3 is not in names"
fi
```

### array_join

How to use: `array_join delimeter array`

Join the array as string by delimeter char, such as
```
names=(1 2 2 3 5 5)

str=$(array_join ", " ${names[@]})
```

the result string is:
```
1, 2, 2, 3, 5, 5
```
