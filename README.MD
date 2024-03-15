[离线包制作](docs/offline_zh.md)

[在线安装](README_online.md)  

[基于ansible离线部署](docs/ansible.md)

> 离线安装



## 部署需求
软件包可以放在harbor服务器，或者上传至各个服务器上，
k8s的各个节点需要访问harbor的443端口以及38088端口

- 443 拉取镜像
- 38088 拉取离线包
- 服务器操作需使用root用户权限

建议配置:
- 1台harbor
- 3台master
- 2台node节点

操作系统:
- centos8
- 建议内核版本>=5.10

## 部署架构

```
  +----------------------+                  +----------------------+
  |       master-1       |                  |        master-2      |
  +----------------------+                  +----------------------+
  |       apiserver      <---------+-------->        apiserver     |
  +----------------------+         |        +----------------------+
  |                      |         |        |                      |
  +----------+ +---------+         |        +---------+ +----------+
  |controller| |scheduler|         |        |scheduler| |controller|
  +----+-----------+-----+         |        +------+----------+----+
       |           |               |               |          |
v------v-----------v  >------------^------------<  v----------v------v
|                     |                         |                    |
| +-------------------+-------------------------+------------------+ |
| |                   |                         |                    |
| +----------+    +-------+      KUBE-VIP   +-------+   +----------+ |
| |                   |                         |                    |
| |                   |                         |                    | 
| +-----------------------+--------^--------+----------------------+ |
|                                  |                                 |
>---->----------->---------->------^----<----------<-----------<-----<
     |           |          |           |          |           |
 +---+-----------+----+ +---+-----------+----+ +---+-----------+----+
 |kubelet| |kube-proxy| |kubelet| |kube-proxy| |kubelet| |kube-proxy|
 +-------+ +----------+ +-------+ +----------+ +-------+ +----------+
 |                    | |                    | |                    |
 +--------------------+ +--------------------+ +--------------------+
 |       node-3       | |       node-3       | |       node-5       |
 +--------------------+ +--------------------+ +--------------------+
```

## 将软件包上传至harbor服务器

```bash
#软件包名称为k8s_install.tar.gz
#然后进行解压
tar -zxvf k8s_install.tar.gz
cd k8s_install
#再次拷贝到本文件夹内，方便其他节点拉取
cp ../k8s_install.tar.gz ./
```
## 配置config.sh

对于apiserver高可用:

是否启用kube-vip，类似是否配置keepalived实现虚拟IP的高可用,如果是true，则必须配置loadbalancer_vip，如果是外部负载均衡需要设置为false，但也需要配置loadbalancer_vip为外部LB地址

```bash
#参考conf/config_example.sh的说明配置conf/config.sh，建议所有信息一次性配置好，方便后面可以直接复用
vi conf/config.sh
#------------harbor配置-----------
harbor_ip=172.21.62.138   #harbor的ip
harbor_hostname=myharbor.mtywcloud.com   #harbor的域名
https_certificate=/etc/harbor/cert/${harbor_hostname}.crt   #https证书
https_private_key=/etc/harbor/cert/${harbor_hostname}.key   #https私钥
data_volume=/data/harbor/registry         #harbor数据目录
harbor_admin_password=S6ag4KXGS   #harbor管理员密码
#------------docker配置-----------
docker_data_root="/data/kubernetes/docker"       #docker数据目录
#----------containerd配置---------
containerd_data_dir="/data/kubernetes/containerd"          #containerd数据目录
#------------k8s配置--------------
master1_ip=172.16.10.206   #master1的ip
master2_ip=192.168.1.212   #master2的ip
master3_ip=192.168.1.213   #master3的ip
kubeadm_dir="/usr/local/bin"        #kubeadm目录
etcd_data_dir="/data/kubernetes/etcd"     #etcd数据目录             
pod_cidr="10.244.0.0/16"             #pod 网段
svc_cidr="10.96.0.0/20"              #service网段
kube_vip_enable=false                 #是否启用kube-vip，类似是否配置keepalived实现虚拟IP的高可用,如果是true，则必须配置loadbalancer_vip，如果是外部负载均衡需要设置为false，但也需要配置loadbalancer_vip
loadbalancer_vip=172.16.10.206        #kube-vip的虚拟IP
kube_vip_eth="ens192"                  #kube-vip使用的网卡，启用kube-vip则必须配置
node_cidr_mask_size="25"            #每个节点所分配的网段掩码
#------------网络插件配置----------
network_type="cilium"               #网络插件类型
#------------其他配置-------------
nfs_enabled="true"   #是否部署nfs stroageclass,主要提供k8s的持久化存储
nfs_server="192.168.1.12"  #nfs服务器地址
nfs_path="/data/nfs/k8s"   #nfs目录
logfile=/var/log/k8s_install.log
date_format=$(date +"%Y-%m-%d %H:%M:%S")
#---------cpu架构配置------------
arch="amd64"  #arm64
arch1="x86_64"  #aarch64
```

## 安装harbor

```bash
# 依次执行
bash 2.init.sh
bash 3.docker_install.sh
bash 4.harbor_install.sh
source conf/config.sh
echo "$harbor_ip $harbor_hostname" >> /etc/hosts #配置本地hosts解析测试harbor的访问
#确保正常之后登录测试
docker login $harbor_hostname --username admin --password $harbor_admin_password
#加载镜像,并上传镜像
bash 5.load_images.sh
#确保harbor的镜像上传成功
token=`echo -n "admin:$harbor_admin_password" | base64`
#不修改默认情况下是YWRtaW46UzZhZzRLWEdT
curl -k -X 'GET'   'https://myharbor.mtywcloud.com/api/v2.0/projects/library/repositories?page=1&page_size=100'   -H 'accept: application/json'   -H 'authorization: Basic "${token}"' |python3 -m json.tool|grep name
```

## harbor服务器上配置下载访问

harbor服务器将会开启38088端口，以供其他服务器下载离线包

```bash
#导入nginx镜像
docker load -i offline/images/amd64/nginx.tar.gz
docker load -i offline/images/amd64/kubespray.tar.gz
docker-compose up -d
#确保启动成功
docker-compose ps 
#访问如下地址可以查看本地代理出去的软件包
$harbor_ip:38088
```

## 配置nfs服务器

登录nfs服务器，或者复用k8s节点的服务器、harbor服务器

nfs需要为后续的监控组件、日志组件等提供持久化存储

如果机器可以联网，可以在线安装所需的软件包
```bash
if [ -f /etc/debian_version ]; then
  apt update && apt install nfs-kernel-server -y
  systemctl enable nfs-kernel-server
  systemctl restart nfs-kernel-server

elif [ -f /etc/redhat-release ]; then
  yum install nfs-utils -y
  systemctl enable rpcbind --now
  systemctl enable nfs-server
  systemctl start nfs-server
else
  yum install nfs-utils -y
  systemctl enable rpcbind --now
  systemctl enable nfs-server
  systemctl start nfs-server
fi
````
如果无法联网，则需要手动安装软件包

离线安装需要找相应系统的软件源,因系统的差异性，本脚本无法集成，目前centos8测试是可以的，本rpm包提取自centos8，其他系统不确保100%安装成功

在nfs服务器上安装nfs rpm包
```bash
bash 1.yum_install.sh
```

配置nfs服务
```bash
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
#确认配置文件，可以直接复制安装harbor时的配置文件
vi conf/config.sh
bash script/k8s/8.nfs-install.sh
#挂载测试
mkdir /test
mount -t nfs 192.168.150.14:/data/nfs/k8s /test
```


## 登录master1的服务器

初始化第一台master节点

------------------------------
当使用nfs存储时，k8s各个节点需要安装nfs客户端才能进行nfs挂载，离线安装需要找相应系统的软件源,因系统的差异性，本脚本无法集成，目前centos8测试是可以的，本rpm包提取自centos8，其他系统不确保100%安装成功

在线安装

```bash
#centos
yum install nfs-utils -y
#挂载测试，IP替换成nfs的IP
mkdir /test
mount -t nfs 192.168.150.14:/data/nfs/k8s /test
#测试成功之后，进行卸载
umount /test
```

离线安装，安装失败则需要自行找nfs软件包安装，脚本会配置yum仓库为本地目录

主要安装k8s需要的软件包，conntrack socat nc bash-completion等命令
```bash
bash 1.yum_install.sh
```
-------------------------------

初始化第一台master节点，依次执行安装

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
#初始化内核参数
bash 2.init.sh
#安装容器运行时
bash 3.docker_install.sh
#导入离线镜像
bash offline/images/amd64/load.sh
#安装k8s
bash 6.k8s_install.sh
```

## 登录master2的服务器

- master2服务器加入到集群中

```bash
#配置master2服务器的hosts解析
hostnamectl set-hostname master2
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
#离线安装k8s所需软件包，某些安装失败则需要自行找相应软件包安装，脚本会配置yum本地目录做为仓库
bash 1.yum_install.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 7.join_master.sh
```

## 登录master3的服务器

- master3服务器加入到集群中

```bash
#配置master3服务器的hosts解析
hostnamectl set-hostname master3
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
#离线安装k8s所需软件包，某些安装失败则需要自行找相应软件包安装，脚本会配置yum本地目录做为仓库
bash 1.yum_install.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 7.join_master.sh
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
#离线安装k8s所需软件包，某些安装失败则需要自行找相应软件包安装，脚本会配置yum本地目录做为仓库
bash 1.yum_install.sh
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
#离线安装k8s所需软件包，某些安装失败则需要自行找相应软件包安装，脚本会配置yum本地目录做为仓库
bash 1.yum_install.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 8.join_node.sh
```

## 等k8s集群初始化完成之后进行组件的安装,这样可以保证组件可以平衡运行在各个节点上

- 登录任一台master节点

确认集群处于正常状态
```bash
kubectl get node -owide
kubectl get cs
```
安装addon组件
默认会安装以下组件，可以根据需求进行增删改,脚本文件位于 vi script/k8s/5.addon.sh

|           |                       |
|     ---   |         ---           |
|      组件名称     |   安装方式        |
| metrics-server    |    yaml           |
| gateway api   crd    |    yaml           |
| metallb-native    |    yaml           |
|    ingress-nginx  |    helm           |
| reloader          |    yaml         |
|  redis            |    yaml   |
| local-path-storage |  yaml   |
| kuboard   |    yaml          |
|   nfs-subdir-external-provisioner  |    helm           |
|  kube-prometheus-stack     |    helm   |
|  loki         | helm  |
| apollo        |   helm    |
| net-tools     |      yaml  |


组件安装
```bash
bash 9.addon_install.sh
```

## 根据需要开启etcd备份

```bash
bash etcd_backup.sh
```

## 开启集群备份

## 后期节点的扩容
### master节点扩容

替换master节点，需要将其他master节点加入到集群中，然后移除旧的master节点
```bash
#配置master4服务器的hosts解析
hostnamectl set-hostname master4
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
#离线安装k8s所需软件包，某些安装失败则需要自行找相应软件包安装，脚本会配置yum本地目录做为仓库
bash 1.yum_install.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 7.join_master.sh
```
这个时候加入已有集群肯定是失败的，因为token过期了，需要重新生成token，再次加入

```bash
#重置本节点
kubeadm --reset --force
```

在master1节点拿取加入master的token
```bash
#可以使用下面命令生成新证书上传，这里会打印出certificate key，后面会用到
CERT_KEY=`kubeadm init phase upload-certs --upload-certs|tail -1`
# 其中 --ttl=0 表示生成的 token 永不失效. 如果不带 --ttl 参数, 那么默认有效时间为24小时. 在24小时内, 可以无数量限制添加 worker.
echo `kubeadm token create --print-join-command --ttl=1h` " --control-plane --certificate-key $CERT_KEY --v=5"
# 拿到上面打印的命令在需要添加的节点上执行
```

### node节点扩容


```bash
#配置node4服务器的hosts解析
hostnamectl set-hostname node4
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
#离线安装k8s所需软件包，某些安装失败则需要自行找相应软件包安装，脚本会配置yum本地目录做为仓库
bash 1.yum_install.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 8.join_node.sh
```
上面加入加入之后肯定也是失败的，因为token过期了，需要重新生成token，再次加入

```bash
master1节点拿取加入master的token
kubeadm token create --print-join-command --ttl=1h
```

```bash
#重置本节点
kubeadm reset --force
# 拿到上面打印的命令在需要添加的节点上执行
```

## 移除master节点

```bash
kubectl drain <master-node-name> --ignore-daemonsets --delete-emptydir-data --force
kubectl delete node <master-node-name>
```

移除etcd

```bash
由于etcd是堆叠部署的
如果旧的master移除，etcd不需要，则需要进行移除
alias etcdctl="ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key"


etcdctl member list #获取成员ID
etcdctl member remove ${memberID}
etcdctl endpoint status --cluster --write-out=table #检查
etcdctl endpoint health --cluster --write-out=table #确保当前集群正常
```

## 移除node节点

```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data --force
kubectl delete node <node-name>
```

## 搭建集群时脚本会关闭节点上防火墙，集群搭建完毕后会使用到如下表列出的端口 [端口](docs/port.md)

## 查看grafana以及kuboard等默认密码 [密码](docs/admin.md)

## etcd常见命令 [etcd](docs/etcd.md)

## kubectl常见命令 [kubectl](docs/kubectl.md)

## faq [faq](docs/faq.md)


