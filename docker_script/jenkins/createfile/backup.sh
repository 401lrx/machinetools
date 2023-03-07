#!/bin/bash

cd `dirname $0`

now=`date "+%Y%m%d_%H%M%S"`
backupdir="jenkins_backup_${now}"

echo "creating backup dir..."
rm -rf ${backupdir}
mkdir ${backupdir}

echo "copy file and dir..."
cp -pf jenkins_home/config.xml ${backupdir}/
cp -rpf jenkins_home/jobs ${backupdir}/
cp -rpf jenkins_home/plugins ${backupdir}/
cp -rpf jenkins_home/users ${backupdir}/

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