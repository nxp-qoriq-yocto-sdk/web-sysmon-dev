#!/bin/sh

########################################################################
#
# Copyright (c) 2014 Freescale Semiconductor, Inc. All rights reserved.
#
########################################################################

USER=root
SYSMONDIR=/usr/rrd
RRDDIR=/var/lib/sensors-rrd
BINPATH=/usr/local/bin
UPDATEDAEMON=/usr/rrd/update_rrd.sh
UPDATEDAEMON_HEAD=/usr/rrd/update_rrd_head
HWMONSYS=/sys/class/hwmon
WEBDIR=/www/pages/senspix
SENSINPUT="temp in curr"
RRDFILEEND="_rrd"

cat $UPDATEDAEMON_HEAD > $UPDATEDAEMON
cat /dev/null > $SYSMONDIR/monitor.conf
for HWMONDIR in $HWMONSYS/*;
do
	SENSDEV=`echo $HWMONDIR | awk -v FS="/" '{print $NF}'`;
	SENSNAME=`cat $HWMONDIR/device/name`;
	SENSADDR=`ls -l $HWMONDIR 2>/dev/null | awk '{print $NF}' | awk -v FS="/" '{print $(NF-2)}'`;
	SENSORS="";

	# start of create and update script
	cat $SYSMONDIR/sens_create_rrd_head > $SYSMONDIR/sens_create_rrd_$SENSDEV
	cat $SYSMONDIR/sens_update_rrd_head > $SYSMONDIR/sens_update_rrd_$SENSDEV

	cd $HWMONDIR/device;

	# scan for "temp in curr" input
	for i in $SENSINPUT
	do
		ls $i*_input  2>/dev/null | sed -e "s#_input##g" > $SYSMONDIR/input_list;
		SENSORS="$SENSORS `cat $SYSMONDIR/input_list`"

		while read line;
		do
			echo "$SENSDEV:$line:minute:'$line of $SENSNAME@i2c$SENSADDR for 10 minutes'" >> $SYSMONDIR/monitor.conf;
			echo "$SENSDEV:$line:hour:'$line of $SENSNAME@i2c$SENSADDR for 1 hour'" >> $SYSMONDIR/monitor.conf;
			sed -e "s#$i#$line#g" $SYSMONDIR/$i$RRDFILEEND >> $SYSMONDIR/sens_create_rrd_$SENSDEV;
		done < "$SYSMONDIR/input_list"
	done
	echo "SENSORS='$SENSORS'" >> $SYSMONDIR/sens_update_rrd_$SENSDEV
	cat $SYSMONDIR/sens_update_rrd_common >> $SYSMONDIR/sens_update_rrd_$SENSDEV

	# scan for "power" input
	ls power*_input  2>/dev/null | sed -e "s#_input##g" > $SYSMONDIR/input_list;
	SENSORS="`cat $SYSMONDIR/input_list`"

	while read line;
	do
		echo "$SENSDEV:$line:minute:'$line of $SENSNAME@i2c$SENSADDR for 10 minutes'" >> $SYSMONDIR/monitor.conf;
		echo "$SENSDEV:$line:hour:'$line of $SENSNAME@i2c$SENSADDR for 1 hour'" >> $SYSMONDIR/monitor.conf;
		sed -e "s#power#$line#g" $SYSMONDIR/power_rrd >> $SYSMONDIR/sens_create_rrd_$SENSDEV;
	done < "$SYSMONDIR/input_list"
	echo "SENSORS='$SENSORS'" >> $SYSMONDIR/sens_update_rrd_$SENSDEV
	cat $SYSMONDIR/sens_update_rrd_power >> $SYSMONDIR/sens_update_rrd_$SENSDEV

	# end of create and update script
	cat $SYSMONDIR/sens_create_rrd_tail >> $SYSMONDIR/sens_create_rrd_$SENSDEV
	cat $SYSMONDIR/sens_update_rrd_tail >> $SYSMONDIR/sens_update_rrd_$SENSDEV

	chmod a+x $SYSMONDIR/sens_create_rrd_$SENSDEV $SYSMONDIR/sens_update_rrd_$SENSDEV;
	$SYSMONDIR/sens_create_rrd_$SENSDEV $RRDDIR/sensors_$SENSDEV.rrd;
	chown $USER $RRDDIR/sensors_$SENSDEV.rrd;
	install -d -o $USER -m 777 $WEBDIR/pix_$SENSDEV;
	install -m 755 $SYSMONDIR/sens_update_rrd_$SENSDEV $BINPATH;
	echo "	$BINPATH/sens_update_rrd_$SENSDEV $RRDDIR/sensors_$SENSDEV.rrd $SENSDEV" >> $UPDATEDAEMON;
done
echo 'sleep 1;' >> $UPDATEDAEMON
echo 'done' >> $UPDATEDAEMON
chmod a+x $UPDATEDAEMON
rm $SYSMONDIR/input_list
