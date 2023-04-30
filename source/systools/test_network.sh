#!/bin/bash
cd `dirname $0`
source /etc/profile

if [ $# -lt 1 ];then
    echo "$0 conf.ini"
fi

conf=$1
if [ ! -f $conf ];then
    echo "conf $conf do not exist"
    exit 1
fi

bash parseini.sh check $conf || exit 1
ping_target=$(bash parseini.sh var $conf "common" "check_ping_target")
recheck_times=$(bash parseini.sh var $conf "common" "recheck_times")
recheck_interval=$(bash parseini.sh var $conf "common" "recheck_interval")
fail_cmd=$(bash parseini.sh var $conf "common" "fail_cmd")

log_path=../../log/test_network.log

for ((i=0; ;i++)); do
    ping -c 1 $ping_target >/dev/null 2>&1
    if (( $? == 0 ));then
        if (( $i > 0 ));then
            echo "`date +'%Y-%m-%d %H:%M:%S'`|ping success, end recheck"
        fi
        break
    else
        echo "`date +'%Y-%m-%d %H:%M:%S'`|ping fail|"$i >> $log_path
        if (( $i >= $recheck_times ));then
            echo "`date +'%Y-%m-%d %H:%M:%S'`|fail enough, do cmd: $fail_cmd" >> $log_path
            `$fail_cmd`
            break
        fi
    fi
    sleep $recheck_interval
done
