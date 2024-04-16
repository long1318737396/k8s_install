## 部署条件
- 确保nfs以部署好

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


**如果是单master节点，则kube-vip设置为false，loadbalancer_vip为master1节点的IP地址,master2和master3的IP地址也都写master1的IP地址即可**

```bash
#配置master1服务器的hosts解析
hostnamectl set-hostname master1
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
```





安装k8s需要的软件包: conntrack socat nc bash-completion等命令

假设已有rpm仓库，如果没有，则阅读[rpm离线安装](./rpm_offline.md)

```bash
bash 1.yum_install_online.sh
```

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

## 登录node1节点

- node1服务器加入到集群中

```bash
#配置node1服务器的hosts解析
hostnamectl set-hostname node1
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
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

- 参考node1服务器加入到集群中

```bash
#配置node2服务器的hosts解析
hostnamectl set-hostname node2
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
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
