LIBDIR?=/etc/clb
INSTALLDIR=$(LIBDIR)/lib

install_lib:
	mkdir -p $(INSTALLDIR)
	cp -r lib/* $(INSTALLDIR)

install: install_lib
