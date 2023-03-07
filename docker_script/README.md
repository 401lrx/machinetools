# DockerScript

## 介绍
docker服务初始化备份脚本。不包含镜像的下载获取。

## 使用
以nginx举例。

## 获取对应的镜像
使用一般方法获取镜像，例如，获取nginx如下：
```
docker pull nginx
docker pull nginx:1.21.6
```
推荐使用指定版本的nginx，而不是latest。

## 创建一个docker容器
首先将nginx文件夹移动或复制到你想运行容器的位置(不要只拷贝create.sh脚本，需要拷贝整个nginx文件夹)。

修改create.sh脚本，更改脚本中镜像版本与获取镜像版本一致。
```
docker run --detach \
        --publish 80:80 \
        --name nginx --restart always \
        --link php-fpm:php \
        --volume ${curpath}/conf.d:/etc/nginx/conf.d \
        --volume ${curpath}/www:/usr/share/nginx/html \
        --volume ${curpath}/logs:/var/log/nginx \
        --volume ${curpath}/nginx.conf:/etc/nginx/nginx.conf \
        --privileged=true \
        nginx:1.21.6    # 修改这里为获取的版本号
```
运行create.sh脚本，即可创建一个nginx容器。

### 修改默认的创建参数
直接修改create.sh脚本中的参数即可。

若新增了volume文件夹，请在createfile下添加对应的文件夹。
```
--volume ${curpath}/conf.d:/etc/nginx/conf.d  # 在createfile下新增conf.d文件夹
```
若新增了volume文件，请在createfile下添加对应文件。
```
--volume ${curpath}/nginx.conf:/etc/nginx/nginx.conf # 在createfile下新增nginx.conf文件
```
可自定义createfile内挂载的文件夹内容(子文件)以及文件内容。


## 对容器的数据进行备份
执行backup.sh脚本，会在nginx目录下自动生成一个backup文件夹，里面会生成一个打包好的备份。

### 修改备份的内容，形式
对backup.sh脚本进行修改，添加所需要的备份操作即可。

添加新操作后，请依旧保持备份后在backup文件夹内生成一个备份文件的形式。便于统一的备份管理。

或是

自行设计备份流程，对docker容器进行统一备份。
