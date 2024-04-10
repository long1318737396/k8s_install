## 介绍

- k8s版本: v1.29.2


- 通过kube-vip实现控制平面的高可用

- 集成ingress-nginx、nfs、kuboard、prometheus等常用组件

- 网络插件支持calico、cilium

- amd64、arm64架构(逐渐完善中.....)
## 架构


```text
+----------------------+                  +----------------------+                     +----------------------+
|       master-1       |                  |       master-2       |                     |       master-3       |
+----------------------+                  +----------------------+                     +----------------------+
|       apiserver      <---------+-------->       apiserver       <---------+---------->       apiserver      |
+----------------------+         |        +----------------------+                     +----------------------+
|                      |         |        |                      |                     |                      |
+----------+ +---------+         |        +---------+ +----------+                     +---------+ +----------+
|controller| |scheduler|         |        |scheduler| |controller|                     |scheduler| |controller|
+----+-----------+-----+         |        +------+----------+----+                     +------+----------+----+
        |           |               |               |          |
-----v-----------v--------------^--------------v-----------v---------------------------v----------------------
|                                                                                                             |
| +-------------------+-------------------------+------------------+ +-------------------+--------------------|
| |                   |                         |                    |                    |                   |
| |                   |                      KUBE-VIP                |                    |                   |
| |                   |                         |                    |                    |                   |
| |                   |                         |                    |                    |                   |
| +-----------------------+--------^----------------------------+----------------------+ +--------------------|
|                                  |                                                                          |
-----v-----------v--------------^--------------v-----------v---------------------------v----------------------
                         |           |               |               |          |
                  +---+-----------+----+ +---+-----------+----+ +---+-----------+----+
                  | kubelet| kube-proxy| | kubelet   |kube-proxy|kubelet  |kube-proxy|
                  +-------+ +----------+ +-------+ +----------+ +-------+ +----------+
                  |                    | |                    | |                    |  
                  +--------------------+ +--------------------+ +--------------------+
                  |       node-1       | |       node-2       | |       node-3       |
                  +--------------------+ +--------------------+ +--------------------+
```


## 部署模式

- 单master

- 多master高可用

- ansible自动化部署（**需要各个服务器的root权限**）


## 部署要求
- 操作系统:
  - 建议内核版本>=5.10

  - 内网建议有ntp服务

- 服务器:

  建议配置:
  - 1台harbor (**建议可以联网**)
  - 1台nfs
  - 3台master
  - 2台node节点

- 配置要求
  - master: cpu cores >= 4, mem >= 16G, 两块数据盘，一块做为containerd数据盘，另一块做为etcd和集群备份
  - node: cpu cores >= 8, mem >= 32G, 一块数据盘
  - nfs: cpu cores >= 4, mem >= 8G，一块nfs数据盘
  - harbor: cpu cores >= 4, mem >= 8G，一块镜像存储数据盘


## 部署步骤


### 1.规划

- k8s以及nfs节点需要通harbor的443端口拉取镜像
- k8s以及nfs节点需要通harbor的38088端口拉取离线包
- 服务器操作需使用root账户

### 2. 配置ntp服务


假设只有harbor可以通外网，harbor做为ntp服务器，其他节点通过harbor同步时间

harbor配置
```bash
# 服务端
# apt install chrony -y
yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool ntp.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 192.168.1.0/24
local stratum 10
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

systemctl restart chronyd ; systemctl enable chronyd
```

其他服务器配置
```bash
# apt install chrony -y
yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool 192.168.1.31 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

systemctl restart chronyd ; systemctl enable chronyd

#使用客户端进行验证
chronyc sources -v
```
```text
# 参数解释
#
# pool ntp.aliyun.com iburst
# 指定使用ntp.aliyun.com作为时间服务器池，iburst选项表示在初始同步时会发送多个请求以加快同步速度。
# 
# driftfile /var/lib/chrony/drift
# 指定用于保存时钟漂移信息的文件路径。
# 
# makestep 1.0 3
# 设置当系统时间与服务器时间偏差大于1秒时，会以1秒的步长进行调整。如果偏差超过3秒，则立即进行时间调整。
# 
# rtcsync
# 启用硬件时钟同步功能，可以提高时钟的准确性。
# 
# allow 192.168.0.0/24
# 允许192.168.0.0/24网段范围内的主机与chrony进行时间同步。
# 
# local stratum 10
# 将本地时钟设为stratum 10，stratum值表示时钟的准确度，值越小表示准确度越高。
# 
# keyfile /etc/chrony.keys
# 指定使用的密钥文件路径，用于对时间同步进行身份验证。
# 
# leapsectz right/UTC
# 指定时区为UTC。
# 
# logdir /var/log/chrony
# 指定日志文件存放目录。
```

### 3.安装指南


**网络插件**
- 默认是cilium的native-routing-eBPF-Host-Routing，对于云服务如果不支持则需要[vxlan模式](./docs/cilium_vxlan.md),或者使用calico
- 对于centos7等系统，则必须升级内核版本，否则会导致bpf挂载不上

软件包可以放在harbor服务器，或者直接上传至各个服务器上


[3.1 harbor安装](docs/harbor.md)

[3.2 nfs安装](docs/nfs.md)


**集群安装，以下三选一**

如果各个节点没有yum仓库，可以通过有公网的站点拉取rpm包，然后拷贝到目标服务器上进行安装

[关于离线rpm包拉取](./docs/rpm_offline.md)

[3.3.1 单master节点集群手动部署](docs/master.md)

[3.3.2 多master高可用集群手动部署](docs/master_ha.md)

[3.3.3 ansible自动化部署](docs/ansible.md)

[3.4 组件安装](./docs/addon.md)
 
## 根据需要开启etcd备份

[etcd备份指南](./docs/etcd_backup.md)

## 根据需要开启集群备份

[单节点单硬盘集群备份指南](./docs/minio-single.md)


## 配置kuboard

[kuboard上添加集群](./docs/kuboard.md)

## 后期节点操作

### 集群扩容

[master节点扩容](./docs/master_add.md)

[node节点扩容](./docs/node_add.md)
### 集群缩容

[移除master节点](./docs/master_remove.md)

[移除node节点](./docs/node_remove.md)



## 搭建集群时脚本会关闭节点上防火墙，集群搭建完毕后会使用到如下表列出的端口

[端口查看](docs/port.md)

## 查看grafana以及kuboard等默认密码

[密码查看](docs/admin.md)

##  [etcd](docs/etcd.md)常见命令

## [kubectl](docs/kubectl.md) 常见命令 

## [faq](docs/faq.md)