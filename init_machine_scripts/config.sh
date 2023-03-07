#!/bin/bash


# path config
script_path=/root/init_machine_scripts
init_step_path=${script_path}/step_init
user_step_path=${script_path}/step_user
tool_path=${script_path}/tools


#################### init config #####################
# init switch, set 1 to enable init_machine.sh
enable_init=1

# system class
# pve centos
# sys_env=centos

# use [init_machine.sh listformatstep] get format step
# fill format step to init_step
# execute from first in order
init_step=(
#fill here
machineboot
preinstall
selinux
vimconf
mymail
#fill end
)


#################### user config #####################


