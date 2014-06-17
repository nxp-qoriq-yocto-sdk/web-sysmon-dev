########################################################################
#
# Copyright (c) 2014 Freescale Semiconductor, Inc. All rights reserved.
#
########################################################################

#
# Edit the following for your setup
#
USER=root
RRDPATH=/usr/bin
RRDDIR=/var/lib/sensors-rrd
WEB=/www/pages
WEBDIR=$(WEB)/senspix
MACH=$(shell uname -n | tr '[a-z]' '[A-Z]')
SENSDIR=/sys/class/hwmon/hwmon0/device
UPDATEDAEMON=/usr/rrd/update_rrd.sh

ifeq ($(MACH),T4240QDS)
RRDUPDATE=sens_update_rrd_t4
else
RRDUPDATE=sens_update_rrd
endif

################################################
# Everything below here should be fine
#

all: install config

config : $(WEBDIR) Makefile monitor.conf
	@./create_cgi.sh

$(RRDDIR) :
	install -d -o $(USER) $(RRDDIR)

$(WEBDIR) :
	install -d -o $(USER) $(WEBDIR)

rrdb : $(RRDDIR)
	@./scan_and_create.sh

$(SENSDIR) :
	$(error error - sensor $(SENSDEV) not installed - check SENSDEV definition in Makefile)

$(WEB) :
	$(error error - Web server directory $(WEB) not present - check WEB definition in Makefile)

install: $(SENSDIR) $(WEB) rrdb
	@$(UPDATEDAEMON) &

clean:
	@./kill_update.sh
	rm -rf sensors.cgi monitor.conf update_rrd.sh sens_create_rrd_hwmon* sens_update_rrd_hwmon* $(WEBDIR)/sensors.cgi $(RRDDIR)
