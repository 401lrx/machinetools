#!/bin/bash

source /etc/profile

cd `dirname $0`

usr=`whoami`
if [[ "$usr" != "root" ]];then
        echo please do script in root.
        exit -1
fi

if [ $# -lt 1 ];then
	echo "$0 backdisk(/dev/sda1)"
	exit 1
fi
disk=$1

now=`date "+%Y%m%d_%H"`

# 准备备份文件夹
backup_root=`pwd`/backup
log_path=${backup_root}/log
log_file=$log_path/$now.log
src_path=${backup_root}/src_disk
dst_path=${backup_root}/backup_disk
info_file=${backup_root}/rsynclist.txt

if [ ! -d "${backup_root}" ];then
        mkdir ${backup_root}
        chmod 777 ${backup_root}
fi

if [ ! -d "${log_path}" ];then
        mkdir ${log_path}
        chmod 777 ${log_path}
fi
if [ ! -d "${src_path}" ];then
        mkdir ${src_path}
        chmod 777 ${src_path}
fi
if [ ! -d "${dst_path}" ];then
        mkdir ${dst_path}
        chmod 777 ${dst_path}
fi

# 开始备份
echo "=================begin backup===============" >> $log_file
echo "begin time:`date`" >> $log_file

backupDir=(
"//192.168.5.211/PublicData"
"//192.168.5.233/docker"
"//192.168.5.211/photo"
)

echo "now:" $now > ${info_file}

echo "mount backup disk....." >> $log_file
mount ${disk} ${dst_path}

for src_dir in ${backupDir[@]};do
        dirname=`basename ${src_dir}`
        echo "mount src:${src_dir}....." >> $log_file
        mount ${src_dir} ${src_path} -t cifs --options "username=backup,password=backup,dir_mode=0777,file_mode=0777,vers=3.0"

        echo "rsync ${src_path} ${dst_path}/${dirname}" >> $log_file
        echo "--------------------------------------------------------------------------" >> ${info_file}
        rsync -hvaiEW --delete --exclude '#recycle' --exclude 'Download' --exclude 'nobackup' --exclude 'Thumbs.db' ${src_path}/ ${dst_path}/${dirname} >> ${info_file}

        echo "umount src:${src_dir}....." >> $log_file
        umount $src_path
done

echo "umount backup disk....." >> $log_file
umount ${dst_path}

# 额外检测一下硬盘健康度
smartresult=`smartctl -H ${disk} | sed -n "s/\(.\+\)\(result: \)\(.\+\)/\3/p"`
if [[ "x${smartresult}" != "xPASSED" ]];then
        subject="[!!! ATTENTION !!!] disk ${disk} may has error !"
        msg="${disk} not healthy, pls check!!!
disk info:
`smartctl -i ${disk}`

disk health:
`smartctl -H ${disk}`

disk info2:
`smartctl -A ${disk}`

disk error:
`smartctl -l error ${disk}`"
        mysendmail send -t "1716318413@qq.com" -m "${msg}" -s "${subject}"
fi

hdparm -Y ${disk}

# 发结果邮件
mysendmail send -t "1716318413@qq.com" -m "每周备份完成，请检查备份情况。" -s "[[每周备份提醒]] ${now}" -f "${info_file}"

echo "end time:`date`" >> $log_file
echo "=================end backup===============" >> $log_file
