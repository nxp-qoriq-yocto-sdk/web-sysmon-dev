#!/bin/sh

########################################################################
#
# Copyright (c) 2014 Freescale Semiconductor, Inc. All rights reserved.
#
########################################################################

trap "back_to_default" SIGINT

back_to_default()
{
	if [ -e /sys/devices/system/cpu/cpu1/online ]
	then
		./cpu_plug_on.sh
	fi

	if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed ]
	then
		./freq_userspace.sh
		./top_freq.sh
	fi

	if [ -e /sys/devices/system/cpu/cpu0/pw20_state ]
	then
		./enable_pw20.sh
	fi

	killall factorial_period.sh 2>/dev/null
	killall factorial.sh 2>/dev/null

	echo "Applying default PM features back."
	exit;
}

cpu_num=`ls /sys/devices/system/cpu/ | grep cpu[0-9] | wc -l`

if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]
then
	gov_str=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`
else
	gov_str=""
fi

while :
do
	echo
	echo "### Static PM feature demo ###"

	period_cycle=2
	if [ -e /sys/devices/system/cpu/cpu0/pw20_state ]
	then
		./disable_pw20.sh
		idle_msg="Idle (PW20 disabled) for 20 seconds."
		period_cycle=`expr $period_cycle + 2`
	else
		idle_msg="Idle for 20 seconds."
	fi

	echo "Fully loaded for 20 seconds."
	for i in `seq 1 $cpu_num`
	do
		./factorial.sh 20 &
	done
	sleep 20;

	echo $idle_msg
	sleep 20;

	if [ -e /sys/devices/system/cpu/cpu1/online ]
	then
		echo "Idle with half cores offline for 20 seconds."
		./cpu_plug_off.sh
		sleep 20;
	fi

	if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed ]
	then
		echo "Idle with half cores offline, online cores in half frequency for 20 seconds."
		./freq_userspace.sh
		./half_freq.sh
		sleep 20;
	fi

	if [ -e /sys/devices/system/cpu/cpu1/online ]
	then
		./cpu_plug_on.sh
	fi

	if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed ]
	then
		./top_freq.sh
	fi

	for str in $gov_str
	do
		if [ $str == "ondemand" ] || [ $str == "conservative" ]
		then
			period_cycle=`expr $period_cycle + 2`
		fi
	done

	echo
	echo "### Dynamic PM feature demo ###"
	echo "(Fully loaded for 20 seconds, Idle for 20 seconds, periodically running in background.)"
	./factorial_period.sh 20 $period_cycle &

	echo "No PM features, two period."
	sleep 80

	if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed ]
	then
		echo "CPUfreq with conservative governor enabled, two period."
		./freq_conservative.sh
		sleep 80
	fi

	if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed ]
	then
		echo "CPUfreq with ondemand governor enabled, two period."
		./freq_ondemand.sh
		sleep 80
	fi

	if [ -e /sys/devices/system/cpu/cpu0/pw20_state ]
	then
		echo "CPUfreq with ondemand governor enabled, PW20 enabled, two period."
		./enable_pw20.sh
		sleep 80
	fi

	if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed ]
	then
		./freq_userspace.sh
		./top_freq.sh
	fi
done
