#!/bin/bash

source /etc/profile

cd `dirname $0`

usr=`whoami`

if [[ "$usr" != "root" ]];then
        echo please do script in root.
        exit -1
fi

function usage()
{
	echo "$0 dockerpath"
	echo "example: $0 /work/docker"
}

if [ $# -lt 1 ];then
	usage
	exit 1
fi

now=`date "+%Y%m%d"`

src_path=$1
if [ ! -d ${src_path} ];then
	echo "docker path is not exists! pls check"
	usage
	exit 1
fi

bak_path=/work/data/docker-bak
dst_path=${bak_path}/${now}
log_path=${dst_path}/backup_${now}.log

if [ ! -d "${dst_path}" ];then
        mkdir -p ${dst_path}
fi

echo "-----------------------------------------------------------------------------------" >> ${log_path}
echo begin backup:`date` >> ${log_path}
for dockerimage in `ls ${src_path}`;do
	echo "------ begin backup ${dockerimage} ------" >> ${log_path}
	backscript=${src_path}/${dockerimage}/backup.sh
	backfiledir=${src_path}/${dockerimage}/backup
	if [ -f ${backscript} ];then
		echo "EXECUTE ${backscript} ..." >> ${log_path} 2>&1
		chmod +x ${backscript}
		bash ${backscript} >> ${log_path}
		echo "EXECUTE ${backscript} done !" >> ${log_path}
		backup_filename=`ls -t ${backfiledir} | head -n1`
		if [[ "x${backup_filename}" == "x" ]];then
			echo "[!!! ATTENTION !!!] ${dockerimage} do not generate backfile, maybe something wrong, pls check!" >> ${log_path}
		else
			echo "${dockerimage} backfile generate done! file is ${backfiledir}/${backup_filename}" >> ${log_path}
			if [ ! -f ${backfiledir}/${backup_filename} ];then
				echo "[!!! ATTENTION !!!] ${backfiledir}/${backup_filename} do not exists, something wrong, pls check!" >> ${log_path}
			else
				mv -vf ${backfiledir}/${backup_filename} ${dst_path}/ >> ${log_path}
			fi
		fi
	else
		echo "${dockerimage} do not have ${backscript}! pls check" >> ${log_path}
	fi
	echo "${dockerimage} backup done!" >> ${log_path}
done

find ${bak_path}/* -mtime +7 -type d -exec rm -rf {} \;
echo end backup:`date` >> ${log_path}
