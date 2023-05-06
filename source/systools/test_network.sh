#!/bin/bash
cd `dirname $0`
source /etc/profile

if [ $# -lt 1 ];then
    echo "$0 conf.ini"
    exit 1
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

log_path=../../log/test_network
log_file=$log_path/test_network.log
mkdir -p -m 755 $log_path

for ((i=0; ;i++)); do
    ping -c 1 $ping_target >/dev/null 2>&1
    if (( $? == 0 ));then
        if (( $i > 0 ));then
            echo "`date +'%Y-%m-%d %H:%M:%S'`|ping success, end recheck" >> $log_file
        fi
        break
    else
        echo "`date +'%Y-%m-%d %H:%M:%S'`|ping fail|"$i >> $log_file
        if (( $i >= $recheck_times ));then
            echo "`date +'%Y-%m-%d %H:%M:%S'`|fail enough, do cmd: $fail_cmd" >> $log_file
            eval "$fail_cmd"
            break
        fi
    fi
    sleep $recheck_interval
done
