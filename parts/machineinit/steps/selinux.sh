#!/bin/bash
cd `dirname $0`

if [ $# -lt 1 ];then
    exit 1
fi

case $1 in
    centos)
        sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
        setenforce 0
    ;;
    pve|ubuntu)
        exit 0
    ;;
    *)
        exit 1
    ;;
esac
