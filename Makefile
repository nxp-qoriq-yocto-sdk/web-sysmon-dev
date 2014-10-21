D?=/
CONFDIR?=$(D)/etc
DESTDIR?=$(D)/usr
AUTORUNDIR?=$(CONFDIR)/init.d


install:
	install -d $(CONFDIR)/
	install -m 644 lighttpd.conf $(CONFDIR)/
	install -d $(D)/usr/local/bin
	cp -r rrd $(DESTDIR)/
	cp -r pm_demo $(DESTDIR)/
	install -d $(AUTORUNDIR)
	install -m 0755 rrd/web-sysmon.sh $(AUTORUNDIR)
