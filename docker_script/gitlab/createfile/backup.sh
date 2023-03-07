#!/bin/bash

cd `dirname $0`

now=`date "+%Y%m%d_%H%M%S"`
backupdir="gitlab_backup_${now}"

echo "creating backup dir..."
rm -rf ${backupdir}
mkdir ${backupdir}

echo "generate backup file..."
docker exec gitlab gitlab-rake gitlab:backup:create >> /dev/null 2>&1
backup_filename=`ls -t data/backups | head -n1`
echo "generate done! file is ${backup_filename}"

echo "copy file and dir..."
cp -pf config/gitlab.rb ${backupdir}/
cp -pf config/gitlab-secrets.json ${backupdir}/
if [[ "x${backup_filename}" == "x" ]];then
    echo "[!!! ATTENTION !!!] backup file not exists, pls check!!!"
else
    cp -pf data/backups/${backup_filename} ${backupdir}/
fi

echo "compress backup dir..."
tar -cvf ${backupdir}.tar ${backupdir}

echo "clean..."
rm -rf ${backupdir}

if [ ! -d backup ];then
    mkdir backup
    chmod 777 backup
fi
mv ${backupdir}.tar backup/
echo "backup done!"