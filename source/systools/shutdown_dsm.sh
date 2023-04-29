#! /usr/bin/bash

host="192.168.5.211"
usr="root"
password="19950127"
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

