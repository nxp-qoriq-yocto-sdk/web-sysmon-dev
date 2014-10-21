#!/bin/sh

########################################################################
#
# Copyright (c) 2014 Freescale Semiconductor, Inc. All rights reserved.
#
########################################################################

CPU_LIST=`cat /proc/cpuinfo | grep processor | awk -v FS=":" '{print $NF}'`

for i in $CPU_LIST
do
	echo 1 > /sys/devices/system/cpu/cpu$i/pw20_state
done
