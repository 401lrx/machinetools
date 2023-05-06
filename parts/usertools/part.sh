#!/bin/bash
cd `dirname $0`
source ../partfunc.sh

partname=usertools
tools_path=tools
install_path=$tools_path/usertools
config_path=config

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
	local user=$2
	local checkuser=`cut -d: -f1 /etc/passwd | grep -e "^$user$"`
	if [[ "x${checkuser}" != "x" ]];then
		normalp "User $user exists"
		return
	fi
	
	useradd -m -d /home/$user -s /bin/bash $user
	passwd $user
	case $1 in
		pve)
			normalp "[!!!! ATTENTION !!!!] please continue manual configure user auth in web GUI /Datacenter/Permissions/Users"
		;;
	esac
	success "User ${user} create done!!! "
}

function createcctool
{
	local user=$2
	local checkuser=`cut -d: -f1 /etc/passwd | grep -e "^$user$"`
	if [[ "x${checkuser}" == "x" ]];then
		error "User $user not exists, cant create cctool"
		return
	fi

	# create prefix/tools/usertools
	createPath $tools_path 777
	createPath $install_path 755
	yes 2>/dev/null | cp -Rf $MACHINE_INIT_WORK_DIR/source/usertools/* $MACHINE_INIT_PREFIX/$install_path/
	chmod -R 755 $MACHINE_INIT_PREFIX/$install_path
	createPath $config_path 777
	normalp "$MACHINE_INIT_PREFIX/$install_path has been installed"

	# create default in prefix/config
	toolsconfig_file=$MACHINE_INIT_PREFIX/$config_path/toolsconfig.txt
	if [ ! -f $toolsconfig_file ];then
		yes 2>/dev/null | cp -f $MACHINE_INIT_WORK_DIR/source/usertools/toolsconfig.txt $MACHINE_INIT_PREFIX/$config_path/
		normalp "$toolsconfig_file has been automatically generated"
	fi
	sshconfig_file=$MACHINE_INIT_PREFIX/$config_path/ssh_getpwd.sh
	if [ ! -f $sshconfig_file ];then
		yes 2>/dev/null | cp -f $MACHINE_INIT_WORK_DIR/source/usertools/ssh_getpwd.sh $MACHINE_INIT_PREFIX/$config_path/
		normalp "$sshconfig_file has been automatically generated"
	fi
	chmod +x $sshconfig_file

	# edit user bashrc, add env
	# delete old
	sed -i '/^# config usertools begin/,/^# config usertools end/d' /home/${user}/.bashrc
	# create new
	echo '# config usertools begin
toolfile='${MACHINE_INIT_PREFIX}/${install_path}/toolsfunc.sh'
toolconfig='${toolsconfig_file}'
sshconfig='${sshconfig_file}'
if [ -f ${toolfile} ];then
		export TOOLS_CONFIG=${toolconfig}
		export SSH_GETPWD=${sshconfig}
		source ${toolfile}
		select_env home
fi
# config usertools end' >> /home/${user}/.bashrc
chown ${user}:${user} /home/${user}/.bashrc
	normalp "env config has been added to /home/${user}/.bashrc"

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
	local ostype=$(getostype)

	# limit to homecc now
	local user="homecc"
	if false ;then
		while true; do
			read -p "Create usertools, please enter user name:" user
			case $user in
				root) normalp "User can not be root"  ;;
				*) break ;;
			esac
		done
	fi

	# create user
	while true; do
		read -p "Do you wish to create user ${user}(yes/no)?" yn
		case $yn in
			[Yy]* ) create_user $ostype $user; break;;
			[Nn]* ) break;;
			* ) normalp "Please answer yes or no";;
		esac
	done

	# create user tools
	while true; do
		read -p "Do you wish to create ${user} tools (yes/no)?" yn
		case $yn in
			[Yy]* ) createcctool $ostype $user; break;;
			[Nn]* ) break;;
			* ) normalp "Please answer yes or no";;
		esac
	done
}

function _clean
{
	local user="homecc"
	# limit to homecc now
	if false ;then
		while true; do
			read -p "Clean usertools, please enter user name:" user
			break
		done
	fi

	# delete prefix/tools/usertools
	rm -rf $MACHINE_INIT_PREFIX/$install_path
	normalp "$MACHINE_INIT_PREFIX/$install_path has been deleted"
	# clean bashrc
	sed -i '/^# config usertools begin/,/^# config usertools end/d' /home/${user}/.bashrc
	normalp "env conf in /home/${user}/.bashrc has been deleted"
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
				[Nn]* ) exit 100;;
				* ) normalp "Please answer yes or no";;
			esac
		done
	;;
	clean)
		while true; do
			read -p "Do you wish to clean ${partname}(yes/no)?" yn
			case $yn in
				[Yy]* ) _clean; break;;
				[Nn]* ) exit 100;;
				* ) normalp "Please answer yes or no";;
			esac
		done
	;;
	help) usage;;
	*) error "Unknow op:" $op;;
esac
