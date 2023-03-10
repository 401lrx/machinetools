#!/bin/bash

cd `dirname $0`
source ../config.sh

if [[ "${sys_env}" == "centos" ]];then
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
    setenforce 0
fi
