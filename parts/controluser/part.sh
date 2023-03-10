#!/bin/bash
cd `dirname $0`

RED="\\E[5;33;41m[ERROR]"
GREEN="\\E[1;32m"
RESET="\\E[0m"
success() { [ $# -ge 1 ] && echo -e $GREEN"$@" $RESET; }
error() { [ $# -ge 1 ] && echo -e $RED"$@" $RESET; }
normalp() { [ $# -ge 1 ] && echo -e $RESET"$@"; }

partname=controluser

function usage
{
    cat << EOF
cur part: $partname
usage: $0 op
    op [install|clean|help]
EOF
}

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
    else
        echo unknow
    fi
}

function _install
{
    ostype=$(getostype)
    case $ostype in
        centos|pve|ubuntu)
            # do something
            error "$ostype not support now"
        ;;
        *)
            error "$ostype not support now"
        ;;
    esac
}

function _clean
{
    ostype=$(getostype)
    case $ostype in
        centos|pve|ubuntu)
            # do something
            error "$ostype not support now"
        ;;
        *)
            error "$ostype not support now"
        ;;
    esac
}

if [[ $# -lt 1 ]];then
    usage
    exit 0
fi

op=$1
case $op in
    install)
        while true; do
            read -p "Do you wish to install ${packname}(yes/no)?" yn
            case $yn in
                [Yy]* ) _install; break;;
                [Nn]* ) exit 1;;
                * ) normalp "Please answer yes or no";;
            esac
        done
    ;;
    clean)
        while true; do
            read -p "Do you wish to clean ${packname}(yes/no)?" yn
            case $yn in
                [Yy]* ) _clean; break;;
                [Nn]* ) exit 1;;
                * ) normalp "Please answer yes or no";;
            esac
        done
    ;;
    help) usage;;
    *) error "Unknow op:" $op;;
esac
