#!/bin/bash
cd `dirname $0`

conf=../../config/sysmail.ini
if [ ! -f $conf ];then
    echo "configure $conf first"
    exit 1
fi
bash parseini.sh check $conf || exit 1

message=""
if [ $# -ge 1 ];then
    message=$1
    shift
fi
subject="[Sys mail from `hostname`]"
if [ $# -ge 1 ];then
    subject="$subject $1"
    shift
fi
file_cmd=()
for ofile in "$@";do
    file_cmd=("${file_cmd[@]}" -f "$ofile")
done

sender=$(bash parseini.sh var $conf "common" "sender")
to=$(bash parseini.sh var $conf "common" "recipient")
mailhost=$(bash parseini.sh var $conf "common" "mailhost")
mailuser=$(bash parseini.sh var $conf "common" "mailuser")
mailpass=$(bash parseini.sh var $conf "common" "mailpass")

python sendmail.py --sender "$sender" -t "$to" --mailhost "$mailhost" --mailuser "$mailuser" --mailpass "$mailpass" -m "$message" -s "$subject" "${file_cmd[@]}" 2>&1 >/dev/null