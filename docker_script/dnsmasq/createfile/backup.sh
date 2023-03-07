#!/bin/bash

cd `dirname $0`

now=`date "+%Y%m%d_%H%M%S"`
backupdir="dnsmasq_backup_${now}"

echo "creating backup dir..."
rm -rf ${backupdir}
mkdir ${backupdir}

echo "copy file and dir..."
cp -pf dnsmasq.conf ${backupdir}/
cp -pf resolv.conf ${backupdir}/
cp -rpf dnsmasq.hosts ${backupdir}/

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