#!/bin/sh

########################################################################
#
# Copyright (c) 2014 Freescale Semiconductor, Inc. All rights reserved.
#
########################################################################

cpu_num=`ls /sys/devices/system/cpu/ | grep cpu[0-9] | wc -l`

for i in `seq 1 $2`
do
	for j in `seq 1 $cpu_num`
	do
		./factorial.sh $1 &
	done
	sleep $1
	sleep $1
done
