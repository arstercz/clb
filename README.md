clb - common library for bash
=============================

`clb` support some common library for bash scripts, this can simplify our work. read more from the following list:

* [workinit](doc/workinit.md)
* [log](doc/log.md)
* [lock](doc/lock.md)
* [utils](doc/utils.md)
* [mktemp](doc/mktemp.md)
* [email](doc/email.md)
* [md5](doc/md5.md)
* [string](doc/string.md)
* [array](doc/array.md)
* [rsync](doc/rsync.md)
* [ssh](doc/ssh.md)
* [process](doc/process.md)
* [mysql](doc/mysql.md)

**note**: all library only test in `Centos/RHEL 6.x/7.x`, `Ubuntu 18.04`, `Debian 10`. 

### How to install?

change to the `clb` source directory, and use `make` to install, default is `/etc/clb`, you can set `LIBDIR` to change the default path:
```
make install

# or
make LIBDIR=/tmp/bashlib install
```

### basic examples

read more from [examples](examples/).

### issue

issue list:

* [issue-list](doc/issue-list.md)  

### TODO

- [x] get more process status;
- [x] add lock common method;
- [x] add rsync common method;
- [x] add mysql common method;
- [ ] add redis common method;
- [ ] add mongodb common method;
