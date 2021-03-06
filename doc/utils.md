## utils

The `utils` library contains some common method:

* [_seq](#_seq)
* [_which](#_which)
* [is_root](#is_root)
* [size_to_bytes](#site_to_bytes)
* [float_compare](#float_compare)

### _seq

How to use: `_seq n`, `n` is greater than 0, such as:
```
for x in $(_seq 5); do
  echo $x
done
```

generate the sequence number: `1 ~ 5`, this is the same as  `seq 1 1 5`.

### _which

How to use: `_which command`, such as:

```
CMD_NMAP=$(_which nmap)

[[ x "$CMD_NMAP" ]] && $CMD_NMAP ...
```

the same as `which command`, but increased error compatibility.

### is_root

determine current effective user is root or not.

### size_to_bytes

convert to bytes size, support `B K M G T`, such as:

```
size_byte=$(size_to_bytes "30M")

echo $size_byte  # 31457280
```

### float_compare

the float compare, print diff number when:
```
1  if f1 >  f2
0  if f1 == f2
-1 if f1 <  f2
```
such as:
```
f1=1.3
f2=1.2
if (( $(float_compare $f1 $f2) > 0)); then
  ...
fi
```
