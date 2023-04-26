#!/bin/bash

RED="\\E[5;33;41m[ERROR]"
GREEN="\\E[1;32m"
RESET="\\E[0m"
success() { [ $# -ge 1 ] && echo -e $GREEN"$@" $RESET; }
error() { [ $# -ge 1 ] && echo -e $RED"$@" $RESET; }
normalp() { [ $# -ge 1 ] && echo -e $RESET"$@"; }

function getostype
{
    local osstr=`uname -a`
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

function createRootDir
{
    if [ ! -d $MACHINE_INIT_PREFIX ]; then
        mkdir -p $MACHINE_INIT_PREFIX
        chmod 777 $MACHINE_INIT_PREFIX
    fi
}

function createPath
{
    # createPath path mode
    # only set final dir mode
    if [ $# -lt 1 ]; then 
        return
    fi
    createRootDir
    mkdir -p $MACHINE_INIT_PREFIX/$1
    if [ $# -gt 1 ]; then
        chmod $2 $MACHINE_INIT_PREFIX/$1
    fi
}
