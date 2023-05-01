#!/bin/bash
source /etc/profile
cd `dirname $0`

if [ $# -lt 1 ];then
    echo "$0 conf.ini"
    exit 1
fi

conf=$1
if [ ! -f $1 ];then
    echo "conf $conf do not exist"
    exit 1
fi

bash parseini.sh check $conf || exit 1

left_bat_per=$(apcaccess | grep BCHARGE | awk -F '[ .]' '{print $4}')
if [[ "x$left_bat_per" == "x" ]];then left_bat_per=0; fi
shutdown_per=$(bash parseini.sh var $conf "common" "shutdown_per")
if [[ "x$shutdown_per" == "x" ]];then shutdown_per=20; fi

if (( $left_bat_per < $shutdown_per )); then
    for section in $(bash parseini.sh section $conf); do
    	if [[ "$section" == "common" ]];then continue; fi
        ip=$(bash parseini.sh var $conf $section "ip")
        user=$(bash parseini.sh var $conf $section "user")
        passwd=$(bash parseini.sh var $conf $section "passwd")

        bash shutdown_ip.sh "$ip" "$user" "$passwd"
    done
fi
