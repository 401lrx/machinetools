# MachineTools
## 介绍

自用的linux机器脚本工具包，目前包含：
- 机器的环境初始化以及初始软件安装。
- 一套管理员用户使用的快捷命令脚本。
- 一套用于日常使用的工具脚本。
- 日常使用的docker容器相关文件。

## 安装与卸载
### 安装

使用下列命令进行脚本包的安装，期间会有多次确认：
```shell
sudo bash machininstall -i
```
编辑 config.sh 文件或者增加 --prefix 参数指定安装目录，默认安装位置为 /work/ 。

### 卸载
使用 -c 参数卸载：
```shell
sudo bash machininstall -c
```

### 指定部件
使用 -l 参数查看当前能安装的部件：
```shell
sudo bash machininstall -l
```
使用 -p 参数指定需要操作的部件：
```shell
sudo bash machininstall -p systools -i
```

## 管理员用户快捷命令
安装部件 usertools ，脚本将被安装到 prefix/tools/usertools 目录下。编辑配置文件 prefix/config/toolsconfig.txt 与 prefix/config/ssh_getpwd.sh。配置项可参考文件 prefix/config/template/toolsconfig.txt.sample 。

*目前管理员用户脚本限制为 homecc 用户。*

常用命令演示如下
```shell
# 跳转机器
mygo worker
# 传输文件
putfile file.tar worker:/work/tmp/
# 跳转目录
c dockerdir
# 切换用户
suex            # 切换root
suex homecc     # 切换homecc
# 查看进程树
pstreeex        # 打印所有进程的进程树
pstreeex .      # 打印当前用户的进程树
pstreeex 2168   # 打印进程 2168 的进程树，从进程 1 开始
```

## 工具脚本
安装部件 systools，脚本将被安装到 prefix/tools/systools 目录下。

部分脚本使用ini配置，位于 prefix/config 目录下，配置模版在 prefix/config/template 目录下。

部分 python 脚本需要 python3 环境。