#!/bin/bash

cd `dirname $0`

now=`date "+%Y%m%d_%H%M%S"`
backupdir="mysql_backup_${now}"

echo "creating backup dir..."
rm -rf ${backupdir}
mkdir ${backupdir}

echo "generate backup file..."
# 全部表格备份
#docker exec -it mysql mysqldump -uhome -phome --all-databases > ${backupdir}/all.sql

# 指定表格备份
backtable=(
)
for table in ${backtable[@]};do
        docker exec -it mysql mysqldump -uhome -phome ${table} > ${backupdir}/${table}.sql
        echo "generate ${table}.sql ..."
done
echo "generate done!"

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