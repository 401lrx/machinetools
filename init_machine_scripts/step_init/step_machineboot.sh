#!/bin/bash

cd `dirname $0`
source ../config.sh

#copy script
rc_script=${tool_path}/root_scripts/rc_dir
root_script=${tool_path}/root_scripts/root_dir

if [[ "${sys_env}" == "centos" ]]; then
	for file in `ls ${rc_script} | grep ".sh"`;do
		cp ${rc_script}/${file} /etc/rc.d/init.d/
		chmod +x /etc/rc.d/init.d/${file}
		chkconfig --add ${file}
		chkconfig ${file} on
	done
fi

workscripts_path=/work/scripts
if [ ! -d ${workscripts_path} ];then
	mkdir -p ${workscripts_path}
fi

cp -r ${root_script}/* ${workscripts_path}/
chmod -R +x ${workscripts_path}/*

