#!/bin/bash
#chkconfig: 2345 99 1
#description: mystartup script

if [ $# -lt 1 ]; then echo "$0 start|stop"; exit 0; fi

op=$1

case "$op" in
    "start" )
        bash /work/scripts/mystart.sh
        ;;
    "stop" )
        bash /work/scripts/mystop.sh
        ;;
esac
