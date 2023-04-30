#!/bin/bash
# working in prefix/tools/systools/backup_disk.sh
# default conf file is prefix/config/backup_disk.ini
# default log file is prefix/log/backup_disk/[nowtime].log

source /etc/profile
cd `dirname $0`

backup_time=`date "+%Y%m%d_%H"`
usr=`whoami`
if [[ "$usr" != "root" ]];then
	echo please do script in root.
	exit 1
fi

backup_conf=../../config/backup_disk.ini
if [ $# -ge 1 ];then
	backup_conf=$1
fi
if [ ! -f $backup_conf ];then
	echo conf $backup_conf do not exist.
	exit 1
fi
bash parseini.sh check $backup_conf || exit 1

log_path=$(bash parseini.sh var $backup_conf "common" "log_path")
if [[ "x$log_path" == "x" ]]; then
	log_path=../../log/backup_disk
fi
log_file=${log_path}/${backup_time}.log
mkdir -p -m 755 $log_path

# 准备临时文件夹
work_dir=`pwd`/__backup_tmp
work_from=${work_dir}/from
work_to=${work_dir}/to

function backuplog
{
	local timenow=`date +'%Y-%m-%d %H:%M:%S'`
	while read line || [[ -n ${line} ]];do
		echo "$timenow|"$line
		echo "$timenow|"$line >> $log_file
		echo "$timenow|"$line >> $work_dir/maillog.log
	done < <(echo "$1")
}

function errorexit
{
	umount $work_from 2>/dev/null
	umount $work_to 2>/dev/null
	rm -rf $work_dir
	exit 1
}

mkdir -p -m 777 $work_from
mkdir -p -m 777 $work_to

# 开始备份
backuplog "==================================================="
backuplog "begin backup"
for section in $(bash parseini.sh section $backup_conf); do
	if [[ "$section" == "common" ]];then continue; fi
	# 准备目录
	from_type=$(bash parseini.sh var $backup_conf $section "from_type")
	case $from_type in
		smb)
			from_address=$(bash parseini.sh var $backup_conf $section "from_address")
			from_dir=$(bash parseini.sh var $backup_conf $section "from_dir")
			user=$(bash parseini.sh var $backup_conf $section "user")
			passwd=$(bash parseini.sh var $backup_conf $section "passwd")
			if [[ "x$from_address" == "x" ]];then
				backuplog "backup conf error|$section|from_address|$from_address"
				errorexit
			fi
			mount //$from_address/$from_dir $work_from -t cifs --options "username=$user,password=$passwd,dir_mode=0777,file_mode=0777,vers=3.0"
			if [ $? -ne 0 ];then
				backuplog "mount smb error|$section|from|//$from_address/$from_dir"
				errorexit
			else
				backuplog "mount smb //$from_address/$from_dir to $work_from"
				real_from=$work_from
			fi
		;;
		*)
		 	backuplog "backup conf error|$section|from_type|$from_type"
			errorexit
		;;
	esac
	to_type=$(bash parseini.sh var $backup_conf $section "to_type")
	case $to_type in
		disk)
			to_address=$(bash parseini.sh var $backup_conf $section "to_address")
			to_dir=$(bash parseini.sh var $backup_conf $section "to_dir")
			if [[ "x$to_address" == "x" ]];then
				backuplog "backup conf error|$section|to_address|$to_address"
				errorexit
			fi
			mount $to_address $work_to
			if [ $? -ne 0 ];then
				backuplog "mount disk error|$section|to|$to_address"
				errorexit
			else
				backuplog "mount disk $to_address to $work_to"
				real_to=$work_to/$to_dir
			fi
		;;
		*)
			backuplog "backup conf error|$section|to_type|$to_type"
			errorexit
		;;
	esac

	# 开始备份
	exclude_cmd=""
	for exclude_one in $(bash parseini.sh var $backup_conf $section "exclude" | sed "s/,/ /g");do
		exclude_cmd="$exclude_cmd --exclude '$exclude_one'"
	done
	backuplog $(rsync -hvaiEW --delete $exclude_cmd $real_from/ $real_to)

	# 卸载目录
	case $from_type in
		smb)
			umount $work_from
			backuplog "umount smb //$from_address/$from_dir"
		;;
	esac
	case $to_type in
		disk)
			umount $work_to
			backuplog "umount disk $to_address"
		;;
	esac
done

backuplog "end backup"

# 删除临时目录
rm -rf $work_dir
