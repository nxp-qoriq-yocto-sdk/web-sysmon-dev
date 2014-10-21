#!/bin/sh

########################################################################
#
# Copyright (c) 2014 Freescale Semiconductor, Inc. All rights reserved.
#
########################################################################

## run factorial computation for $1 seconds ##

s_start=`date +%s`
duration=0

while [[ $duration -lt $1 ]]
do
	factorial=1
	for a in `seq 1 500`
	do
		factorial=`expr $factorial \* $a`
	done

	s_cur=`date +%s`
	duration=`expr $s_cur - $s_start`
done
