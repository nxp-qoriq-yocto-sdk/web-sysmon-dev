#!/bin/sh

########################################################################
#
# Copyright (c) 2014 Freescale Semiconductor, Inc. All rights reserved.
#
########################################################################

CPU_NUM=`ls /sys/devices/system/cpu/ | grep cpu[0-9] | wc -l`
CPU_MID=`expr $CPU_NUM / 2`
CPU_LAST=`expr $CPU_NUM - 1`

for i in `seq $CPU_MID $CPU_LAST`
do
	echo 1 > /sys/devices/system/cpu/cpu$i/online
done
