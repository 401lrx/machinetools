#!/bin/bash
cd `dirname $0`
source ../partfunc.sh

partname=controluser

function usage
{
    cat << EOF
cur part: $partname
usage: $0 op
    op [install|clean|help]
EOF
}

function create_user
{
    user=$2
    useradd -m -d /home/$user -s /bin/bash $user
    passwd $user
    case $1 in
        pve)
            normalp "[!!!! ATTENTION !!!!] please continue manual configure user auth in web GUI /Datacenter/Permissions/Users"
        ;;
    esac
    success "User ${user} create done!!! "

    ln -s /work/config/toolsfunc /home/${user}/toolsfunc

    # bashrc
    echo '
#config toolsfunc
if [ -f ~/toolsfunc/toolsfunc.sh ];then
        source ~/toolsfunc/toolsfunc.sh
        select_env home
fi' >> /home/${user}/.bashrc
chown ${user}:${user} /home/${user}/.bashrc

    # pve6 use bash_profile
    case $1 in
        pve)
            echo '
if [ -n "$BASH_VERSION" ]; then  
    # include .bashrc if it exists  
    if [ -f "$HOME/.bashrc" ]; then  
        . "$HOME/.bashrc"  
    fi  
fi' >> /home/${user}/.bash_profile
            chown ${user}:${user} /home/${user}/.bash_profile
        ;;
    esac
}

function _install
{
    ostype=$(getostype)

    # create /work/config
    work_cfg=/work/config
    tools_cfg=${work_cfg}/toolsfunc
    if [ ! -d "${tools_cfg}" ];then
        mkdir -p ${tools_cfg}
        chmod 777 /work
        chmod 777 ${work_cfg}

        # copy files
        cp -R tools/* ${tools_cfg}/
        chmod -R 755 ${tools_cfg}

        success "toolsfunc config init done!!!"
    else
        normalp "toolsfunc has been exists."
    fi  

    # create user
    # limit to create homecc now
    if false ;then
        while true; do
            read -p "Create cc user, please enter user name:" username
            case $username in
                root)
                    normalp "User can not be root" 
                ;;
                *)
                    checkuser=`cut -d: -f1 /etc/passwd | grep -e "^$username$"`
                    if [[ "x${checkuser}" != "x" ]];then
                        normalp "User $username exists"
                    else
                        create_user $ostype $username
                        break
                    fi
                ;;
            esac
        done
    else
        username=homecc
        checkuser=`cut -d: -f1 /etc/passwd | grep -e "^$username$"`
        if [[ "x${checkuser}" != "x" ]];then
            normalp "User $username exists"
        else
            create_user $ostype $username
        fi
    fi
}

function _clean
{
    ostype=$(getostype)
    case $ostype in
        centos|pve|ubuntu)
            normalp "$partname not support clean"
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
            read -p "Do you wish to install ${partname}(yes/no)?" yn
            case $yn in
                [Yy]* ) _install; break;;
                [Nn]* ) exit 1;;
                * ) normalp "Please answer yes or no";;
            esac
        done
    ;;
    clean)
        while true; do
            read -p "Do you wish to clean ${partname}(yes/no)?" yn
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
