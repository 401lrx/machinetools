#!/bin/bash

RED="\\E[5;33;41m[ERROR]"
GREEN="\\E[1;32m"
RESET="\\E[0m"
success() { [ $# -ge 1 ] && echo -e $GREEN"$@" $RESET; }
error() { [ $# -ge 1 ] && echo -e $RED"$@" $RESET; }
normalp() { [ $# -ge 1 ] && echo -e $RESET"$@"; }

function getostype
{
    osstr=`uname -a`
    osstr=${osstr,,}
    if [[ $osstr =~ "centos" ]];then
        echo centos
    elif [[ $osstr =~ "pve" ]];then
        echo pve
    elif [[ $osstr =~ "ubuntu" ]];then
        echo ubuntu
    elif [ -f /etc/redhat-release ];then
        osstr=`cat /etc/redhat-release`
        osstr=${osstr,,}
        if [[ $osstr =~ "centos" ]];then
            echo centos
        fi
    else
        echo unknow os
    fi
}