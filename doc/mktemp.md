## mktemp

The `mktemp` library contains make and destroy temp directory:

* [mk_tempdir]
* [rm_tempdir]

> `WT_TMPDIR` will be changed after `mk_tempdir`, `WT_TMPDIR` is different with `WT_WORK_TEMP`.

### mk_tempdir

How to use: `mk_tempdir [dir]`, the `dir` optional, create in `/tmp` by default. such as:
```
mk_tempdir "/export/test/temp"
```

`WT_TMPDIR` will be change when create temp ok, and return `Cannot make secure tmpdir` if create error.

### rm_tempdir

How to use: `rm_tempdir`

such as:
```
rm_tempdir
```

`rm_tempdir` will remove the `WT_TMPDIR` directory, and reset the `WT_TMPDIR` variable.
