#!/bin/sh

########################################################################
#
# Copyright (c) 2014 Freescale Semiconductor, Inc. All rights reserved.
#
########################################################################

case "$1" in
    start|restart)
    echo -n "Starting web based system monitor... "
    cd /usr/rrd
    make clean > /dev/null
    make > /dev/null
    echo "done."
    exit 0
    ;;

    stop)
    exit 0
    ;;

    *)
    echo "Usage: $0 {start|restart|stop}"
    exit 2
esac
exit 0
