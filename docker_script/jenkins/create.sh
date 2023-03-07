#!/bin/bash

cd `dirname $0`

function usage()
{
	echo "$0 op"
    echo "      op=1: create file or dir only not exists."
    echo "      op=2: force create file or dir, replace the same one."
}

if [ $# -lt 1 ];then
	usage
	exit 1
fi

op=$1
chmod -R 777 ./createfile
if (( op == 1 ));then
    awk 'BEGIN {cmd="cp -rpi ./createfile/* ./ "; print "n" |cmd; }'
elif (( op == 2 ));then
    cp -rpf ./createfile/* ./
fi

curpath=`pwd`
docker run --detach \
        --publish 12500:50000 --publish 12880:8080 \
        --name jenkins --restart unless-stopped \
        --log-opt "max-size=5m" \
        --volume ${curpath}/jenkins_home:/var/jenkins_home \
        --privileged=true \
        jenkins/jenkins:2.345