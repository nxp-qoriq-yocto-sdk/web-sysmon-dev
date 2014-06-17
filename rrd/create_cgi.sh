#!/bin/sh

########################################################################
#
# Copyright (c) 2014 Freescale Semiconductor, Inc. All rights reserved.
#
########################################################################

RRDPATH=/usr/bin
WEB=/www/pages
WEBDIR=$WEB/senspix
RRDDIR=/var/lib/sensors-rrd
MACH=`uname -n | tr '[a-z]' '[A-Z]'`

sed -e "s#%%RRDPATH%%#$RRDPATH#g;s#%%MACH%%#$MACH#g" sensors_head > sensors.cgi
while read line;
do
	SENSDEV=`echo $line | awk -v FS=":" '{print $1}'`;
	MONTERM=`echo $line | awk -v FS=":" '{print $2}'`;
	DURATION=`echo $line | awk -v FS=":" '{print $3}'`;
	CHARTDESC=`echo $line | awk -v FS=":" '{print $NF}'`;
	MONTERM_NONUM=`echo $MONTERM | awk -v FS="[0-9]" '{print $1}'`;
	sed -e "s#%%MONTERM%%#$MONTERM#g;s#%%WEBDIR%%#$WEBDIR#g;s#%%RRDDIR%%#$RRDDIR#g;s#%%MACH%%#$MACH#g;s#%%SENSDEV%%#$SENSDEV#g;s#%%CHARTDESC%%#$CHARTDESC#g" $DURATION/sens_$MONTERM_NONUM >> sensors.cgi;
done < "monitor.conf"
cat sensors_tail >> sensors.cgi
install -m 755 sensors.cgi $WEBDIR
