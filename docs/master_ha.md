## 部署条件
- 确保nfs已部署好

- 验证nfs是否可以正常挂载

- 如果操作系统节点内核低于4.19,建议使用calico网络插件

```bash
#centos
yum install nfs-utils -y
#挂载测试，IP替换成nfs的IP
mkdir /test
mount -t nfs 192.168.150.14:/data/nfs/k8s /test
touch /test/test.txt
#测试成功之后，进行卸载
umount /test
```

## 登录master1服务器



初始化第一台master节点，依次执行安装

```bash
#配置master1服务器的hostname
hostnamectl set-hostname master1
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
unzip -j offline/bin/amd64/bin.zip -d offline/bin/amd64/
unzip -j offline/images/amd64/images.zip -d offline/images/amd64/
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
```
安装k8s需要的软件包: conntrack socat nc bash-completion等命令

假设已有rpm仓库，如果没有，则阅读[rpm离线安装](./rpm_offline.md)
```bash
bash 1.yum_install_online.sh
```
-------------------------------
```bash
#初始化内核参数
bash 2.init.sh
#安装容器运行时
bash 3.docker_install.sh
#导入离线镜像
bash offline/images/amd64/load.sh
#安装k8s
bash 6.k8s_install.sh
```

## 登录master2服务器

- master2加入到集群中

```bash
#配置master2服务器的hostname
hostnamectl set-hostname master2
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
unzip -j offline/bin/amd64/bin.zip -d offline/bin/amd64/
unzip -j offline/images/amd64/images.zip -d offline/images/amd64/
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
#安装k8s所需软件包
bash 1.yum_install_online.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 7.join_master.sh
```

## 登录master3服务器

- master3加入到集群中

```bash
#配置master3服务器的hostname
hostnamectl set-hostname master3
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
unzip -j offline/bin/amd64/bin.zip -d offline/bin/amd64/
unzip -j offline/images/amd64/images.zip -d offline/images/amd64/
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
#安装k8s所需软件包
bash 1.yum_install_online.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 7.join_master.sh
```

## 登录node1节点

- node1加入到集群中

```bash
#配置node1服务器的hostname
hostnamectl set-hostname node1
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
unzip -j offline/bin/amd64/bin.zip -d offline/bin/amd64/
unzip -j offline/images/amd64/images.zip -d offline/images/amd64/
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
#安装k8s所需软件包
bash 1.yum_install_online.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 8.join_node.sh
```


## 其他node节点

- 参考node1加入到集群中

```bash
#配置node2服务器的hostname
hostnamectl set-hostname node2
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
unzip -j offline/bin/amd64/bin.zip -d offline/bin/amd64/
unzip -j offline/images/amd64/images.zip -d offline/images/amd64/
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
#安装k8s所需软件包
bash 1.yum_install_online.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 8.join_node.sh
```

