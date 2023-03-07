# InitMachineScript

## 介绍
用于初始化服务器的脚本，以及一些日常使用的工具脚本。

## 使用
包含以下两个部分：

初始化机器的环境。

工具脚本进行备份等操作。

# 初始化服务器环境
拷贝 init_machine_script 文件夹至 /root/ 下，并给 sh 文件赋予执行权限。

修改config.sh脚本。
```
# 允许脚本进行机器初始化
enable_init=1

# 修改为脚本文件夹所在路径
script_path=/root/init_machine_scripts

# 设置系统类型，目前支持pve centos(debian系应该都支持为pve环境)
sys_env=centos

# 选择要进行的初始化步骤， 如下有machineboot， preinstall， selinux设置三个步骤
init_step=(
#fill here
machineboot
preinstall
selinux
#fill end
)
```

## 自定义初始化步骤
例如，添加步骤mystep。
- 在 step_init 文件夹下新增step_mystep.sh脚本。
- 在config.sh的 init_step 中增加 mystep。
```
init_step=(
#fill here
machineboot
preinstall
selinux
mystep          # 增加步骤
#fill end
)
```

# 工具脚本
工具脚本在 tools/root_scripts/root_dir 内。
初始化完成后，会在/work/下生成scripts文件夹，包含所有工具脚本。

其中：

- mystart.sh mystop.sh 两个脚本为开机和停机的时候调用，一些开机或者关机时需要进行的操作可以添加到脚本中。
- backup文件夹内为数据备份脚本。
- gen_docker_bak.sh 对docker数据进行备份，指定docker目录，脚本遍历目录内docker文件夹，并调用backup.sh脚本，最后汇总备份文件。
- shudown_dsm.sh 群辉关机脚本。
