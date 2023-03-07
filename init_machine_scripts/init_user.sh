#!/bin/bash

cd `dirname $0`
source config.sh
source machine_func.sh

function usage()
{
        echo "$0 user"
}

if [ $# -lt 1 ];then
        usage
        exit 1
fi

if [[ "$script_path" != "`pwd`" ]];then
        echo "need put scripts dir in /root/"
        exit 1
fi

if [[ "x${sys_env}" == "x" ]];then
	echo "sys_env not configure, pls set sys_env config in config.sh"
	exit 1
fi

user=$1
if [[ "$user" == "root" ]]; then
	echo "user cant be root"
	exit 1
fi

echo "*************** begin init user ***************"

#if user not exist, create user
checkuser=`cut -d: -f1 /etc/passwd | grep -e "^$user$"`
if [[ "x${checkuser}" == "x" ]];then
	#create user
        if [[ "${sys_env}" == "centos" ]];then
                echo "user not exist, create....."
                useradd $user
                echo "enter user password:"
                passwd $user
                echo "init user authority....."
                usermod -a -G wheel $user
                echo "user ${user} create done!!! "
                echo ""
        elif [[ "${sys_env}" == "pve" ]];then
                echo "user not exist, create....."
                useradd -m -d /home/$user -s /bin/bash $user
                mkdir /home/$user
                chmod 700 /home/$user
                chown $user:$user /home/$user
                echo "enter user password:"
                passwd $user
                echo "init user authority....."
                echo "[!!!! ATTENTION !!!!] please continue manual configure user auth in web GUI /Datacenter/Permissions/Users"
                echo "user ${user} create done!!! "
                echo ""
        fi
fi

echo "init toolsfunc cfg"
# create /work/config
work_cfg=/work/config
tools_cfg=${work_cfg}/toolsfunc
if [ ! -d "${tools_cfg}" ];then
        if [ ! -d "${work_cfg}" ];then
                mkdir -p ${work_cfg}
        fi
        chmod -R 777 /work

        # copy files
        cp -r ${tool_path}/user_toolsfunc ${tools_cfg}
        chmod -R 777 ${tools_cfg}

        echo "toolsfunc config init done!!!"
else
        echo "toolsfunc has been exists."
fi

ln -s ${tools_cfg} /home/${user}/toolsfunc

echo '
#config toolsfunc
#need pre config env in toolsconfig.txt then config select_env in this file
if [ -f ~/toolsfunc/toolsfunc.sh ];then
        source ~/toolsfunc/toolsfunc.sh
        #select_env lrx
fi' >> /home/${user}/.bashrc
chown ${user}:${user} /home/${user}/.bashrc

if [[ "${sys_env}" == "pve" ]];then
        echo '
if [ -n "$BASH_VERSION" ]; then  
    # include .bashrc if it exists  
    if [ -f "$HOME/.bashrc" ]; then  
        . "$HOME/.bashrc"  
    fi  
fi' >> /home/${user}/.bash_profile
        chown ${user}:${user} /home/${user}/.bash_profile
fi

#vimconf
if [[ "${sys_env}" == "centos" ]];then
    if [ -f /etc/vimrc ];then
        cp /etc/vimrc /home/${user}/.vimrc
    fi
elif [[ "${sys_env}" == "pve" ]];then
    if [ -f /etc/vim/vimrc ];then
        cp /etc/vim/vimrc /home/${user}/.vimrc
    fi
fi

if [ -f /home/${user}/.vimrc ];then
    echoVimConf >> /home/${user}/.vimrc
fi

echo "*************** init user done ***************"

echo "[!!!! ATTENTION !!!!] please continue manual configure:"
echo "/home/${user}/toolsfunc/ssh_getpwd.sh"
echo "/home/${user}/toolsfunc/toolsconfig.txt"
echo "/home/${user}/.bashrc"


