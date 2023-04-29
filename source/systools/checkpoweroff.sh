#!/bin/bash
cd `dirname $0`

left_bat_per=$(apcaccess | grep BCHARGE | awk -F '[ .]' '{print $4}')

usr=root
password=19950127
ips=(
192.168.5.253
192.168.5.212
)
if [ ${left_bat_per} -lt 20 ];then
    for host in "${ips[@]}";do
    /usr/bin/expect << EOF
set timeout 15
spawn ssh $usr@$host
expect {
	"yes/no" {send "yes\r"; exp_continue}
	"*assword:" {send "$password\r"}
}
expect "#" {
	send "poweroff\r"
}
expect eof
exit
EOF
    done
fi
