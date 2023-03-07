#!/bin/bash

cd `dirname $0`
source config.sh

if [[ "$script_path" != "`pwd`" ]];then
	echo "need put scripts dir in /root/"
	exit 1
fi

start_time=`date +%s`
echo "***************** begin update:`date '+%Y-%m-%d %H:%M:%S'` *****************"

root_script=${tool_path}/root_scripts/root_dir

workscripts_path=/work/scripts
if [ ! -d ${workscripts_path} ];then
	mkdir -p ${workscripts_path}
fi

chmod -R +x ${root_script}/*.sh ${root_script}/*.py
rsync -haivW \
--exclude 'mystart.sh' --exclude 'mystop.sh' \
${root_script}/ ${workscripts_path}

end_time=`date +%s`
echo "***************** end update:`date '+%Y-%m-%d %H:%M:%S'` *****************"
echo "running time:"$((${end_time}-${start_time}))
