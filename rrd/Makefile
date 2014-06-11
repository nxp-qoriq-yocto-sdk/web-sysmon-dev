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
BINPATH=/usr/local/bin
RRDDIR=/var/lib/sensors-rrd
APACHE=/www/pages
APACHDIR=$(APACHE)/senspix
MACH=$(shell uname -n | tr '[a-z]' '[A-Z]')
UPDATEDAEMON=/usr/rrd/update_rrd.sh
HWMONSYS=/sys/class/hwmon
SENSDIR=/sys/class/hwmon/hwmon0/device

ifeq ($(MACH),T4240QDS)
RRDUPDATE=sens_update_rrd_t4
else
RRDUPDATE=sens_update_rrd
endif

################################################
# Everything below here should be fine
#

all: $(RRDDIR) $(APACHDIR) $(SENSDIR) sensors.cgi

sensors.cgi : Makefile monitor.conf
	@sed -e "s#%%RRDPATH%%#$(RRDPATH)#g;s#%%MACH%%#$(MACH)#g" sensors_head > sensors.cgi
	@while read line;        \
	do      \
		SENSDEV=`echo $$line | awk -v FS=":" '{print $$1}'`;      \
		MONTERM=`echo $$line | awk -v FS=":" '{print $$2}'`;     \
		DURATION=`echo $$line | awk -v FS=":" '{print $$3}'`;     \
		CHARTDESC=`echo $$line | awk -v FS=":" '{print $$NF}'`;     \
		MONTERM_NONUM=`echo $$MONTERM | awk -v FS="[0-9]" '{print $$1}'`;     \
	sed -e "s#%%MONTERM%%#$$MONTERM#g;s#%%APACHDIR%%#$(APACHDIR)#g;s#%%RRDDIR%%#$(RRDDIR)#g;s#%%MACH%%#$(MACH)#g;s#%%SENSDEV%%#$$SENSDEV#g;s#%%CHARTDESC%%#$$CHARTDESC#g" $$DURATION/sens_$$MONTERM_NONUM >> sensors.cgi;	\
	done < "/usr/rrd/monitor.conf"
	@cat sensors_tail >> sensors.cgi
	install -m 755 sensors.cgi $(APACHDIR)

$(RRDDIR) :
	install -d -o $(USER) $(RRDDIR)

$(APACHDIR) :
	install -d -o $(USER) $(APACHDIR)

rrdb : $(RRDDIR)
	@for HWMONDIR in $(HWMONSYS)/*;	\
	do	\
		SENSDEV=`echo $$HWMONDIR | awk -v FS="/" '{print $$NF}'`;	\
		RRDB=$(RRDDIR)/sensors_$$SENSDEV.rrd;	\
		./sens_create_rrd $$RRDB;	\
		chown $(USER) $$RRDB;	\
		install -d -o $(USER) -m 777 $(APACHDIR)/pix_$$SENSDEV;	\
		echo '	/usr/local/bin/$(RRDUPDATE)' $$RRDB $$SENSDEV >> $(UPDATEDAEMON);	\
	done
	@echo 'sleep 1;' >> $(UPDATEDAEMON)
	@echo 'done' >> $(UPDATEDAEMON)
	
$(SENSDIR) :
	$(error error - sensor $(SENSDEV) not installed - check SENSDEV definition in Makefile)

$(APACHE) :
	$(error error - Web server directory $(APACHE) not present - check APACHE definition in Makefile)

install: rrdb $(SENSDIR) $(APACHE)
	install -m 755 $(RRDUPDATE) $(BINPATH)
	@$(UPDATEDAEMON) &

clean:
	rm -rf sensors.cgi $(APACHDIR)/sensors.cgi $(RRDDIR)
