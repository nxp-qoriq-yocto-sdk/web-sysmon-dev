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


cat $UPDATEDAEMON_HEAD > $UPDATEDAEMON
cat /dev/null > $SYSMONDIR/monitor.conf
for HWMONDIR in $HWMONSYS/*;
do
	SENSDEV=`echo $HWMONDIR | awk -v FS="/" '{print $NF}'`;
	SENSNAME=`cat $HWMONDIR/device/name`;
	SENSADDR=`ls -l $HWMONDIR 2>/dev/null | awk '{print $NF}' | awk -v FS="/" '{print $(NF-2)}'`;
	SENSORS="";

	case $SENSADDR in
		"6-0040")
			HWMON_CPU=$SENSDEV;;
		"6-0041")
			HWMON_CPU1=$SENSDEV;;
		"6-0044")
			HWMON_DDR=$SENSDEV;;
		"6-0045")
			HWMON_CPU2=$SENSDEV;;
		"6-0046")
			HWMON_CPU3=$SENSDEV;;
		"6-0047")
			HWMON_CPU4=$SENSDEV;;
		"7-004c")
			HWMON_ADT=$SENSDEV;;
	esac
done

echo "$HWMON_CPU:in1:minute:'CPU voltage for 10 minutes'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_CPU:in1:hour:'CPU voltage for 1 hour'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_CPU:curr1:minute:'CPU current for 10 minutes'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_CPU:curr1:hour:'CPU current for 1 hour'" >> $SYSMONDIR/monitor.conf;

echo "$HWMON_DDR:in1:minute:'DDR voltage for 10 minutes'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_DDR:in1:hour:'DDR voltage for 1 hour'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_DDR:curr1:minute:'DDR current for 10 minutes'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_DDR:curr1:hour:'DDR current for 1 hour'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_DDR:power1:minute:'DDR power for 10 minutes'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_DDR:power1:hour:'DDR power for 1 hour'" >> $SYSMONDIR/monitor.conf;

echo "$HWMON_ADT:temp1:minute:'Motherboard temperature for 10 minutes'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_ADT:temp1:hour:'Motherboard temperature for 1 hour'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_ADT:temp2:minute:'CPU temperature for 10 minutes'" >> $SYSMONDIR/monitor.conf;
echo "$HWMON_ADT:temp2:hour:'CPU temperature for 1 hour'" >> $SYSMONDIR/monitor.conf;

# create and update CPU rrd database for ina220
sed -e "s#HWMON_CPU1#$HWMON_CPU1#g;s#HWMON_CPU2#$HWMON_CPU2#g;s#HWMON_CPU3#$HWMON_CPU3#g;s#HWMON_CPU4#$HWMON_CPU4#g" $SYSMONDIR/T4240QDS/sens_update_rrd_t4_cpu_template > $SYSMONDIR/T4240QDS/sens_update_rrd_t4_cpu;
chmod a+x $SYSMONDIR/T4240QDS/sens_update_rrd_t4_cpu;
$SYSMONDIR/T4240QDS/sens_create_rrd_t4_cpu $RRDDIR/sensors_$HWMON_CPU.rrd;
chown $USER $RRDDIR/sensors_$HWMON_CPU.rrd;
install -d -o $USER -m 777 $WEBDIR/pix_$HWMON_CPU;
install -m 755 $SYSMONDIR/T4240QDS/sens_update_rrd_t4_cpu $BINPATH;
echo "	$BINPATH/sens_update_rrd_t4_cpu $RRDDIR/sensors_$HWMON_CPU.rrd $HWMON_CPU" >> $UPDATEDAEMON;

# create and update DDR rrd database for ina220
$SYSMONDIR/T4240QDS/sens_create_rrd_t4_ddr $RRDDIR/sensors_$HWMON_DDR.rrd;
chown $USER $RRDDIR/sensors_$HWMON_DDR.rrd;
install -d -o $USER -m 777 $WEBDIR/pix_$HWMON_DDR;
install -m 755 $SYSMONDIR/T4240QDS/sens_update_rrd_t4_ddr $BINPATH;
echo "	$BINPATH/sens_update_rrd_t4_ddr $RRDDIR/sensors_$HWMON_DDR.rrd $HWMON_DDR" >> $UPDATEDAEMON;

# create and update temperature rrd database for adt7461
$SYSMONDIR/T4240QDS/sens_create_rrd_t4_adt $RRDDIR/sensors_$HWMON_ADT.rrd;
chown $USER $RRDDIR/sensors_$HWMON_ADT.rrd;
install -d -o $USER -m 777 $WEBDIR/pix_$HWMON_ADT;
install -m 755 $SYSMONDIR/T4240QDS/sens_update_rrd_t4_adt $BINPATH;
echo "	$BINPATH/sens_update_rrd_t4_adt $RRDDIR/sensors_$HWMON_ADT.rrd $HWMON_ADT" >> $UPDATEDAEMON;

echo 'sleep 1;' >> $UPDATEDAEMON
echo 'done' >> $UPDATEDAEMON
chmod a+x $UPDATEDAEMON
