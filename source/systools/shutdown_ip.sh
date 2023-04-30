#! /usr/bin/bash

if [ $# -lt 4 ];then
	echo "$0 host usr password"
	echo "Example: $0 192.168.1.1 test testpass"
	exit 1
fi

host=$1
usr=$2
password=$3
cmd="poweroff"

/usr/bin/expect << EOF
set timeout 15
spawn ssh $usr@$host
expect {
	"yes/no" {send "yes\r"; exp_continue}
	"*assword:" {send "$password\r"}
}
expect "#" {
	send "$cmd\r"
}
expect eof
exit
EOF

