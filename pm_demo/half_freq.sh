#!/bin/sh

########################################################################
#
# Copyright (c) 2014 Freescale Semiconductor, Inc. All rights reserved.
#
########################################################################

CPU_LIST=`cat /proc/cpuinfo | grep processor | awk -v FS=":" '{print $NF}'`

for i in $CPU_LIST
do
	TOP_FREQ=`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_available_frequencies | tr " " "\n" | sort -rn | head -1`
	HALF_FREQ=`expr $TOP_FREQ / 2`
	echo $HALF_FREQ > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_setspeed
done
