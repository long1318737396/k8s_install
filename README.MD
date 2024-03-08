[离线包制作](docs/offline_zh.md)

> 离线安装 | [在线安装](README_online.md)


## 将软件包上传至harbor服务器

```bash
#软件包名称为k8s_install.tar.gz
#然后进行解压
tar -zxvf k8s_install.tar.gz
cd k8s_install
```
## 配置config.sh

```bash
#参考conf/config_example.sh的说明配置conf/config.sh
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
nfs_enabled="true"   #是否部署nfs
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
bash 1.yum_install.sh
bash 2.init.sh
bash 3.docker_install.sh
bash 4.harbor_install.sh
$harbor_ip $harbor_hostname  配置本地hosts解析测试harbor的访问
#确保正常之后登录测试
source conf/config.sh
docker login $harbor_hostname --username admin --password $harbor_admin_password
#加载镜像,并上传镜像
bash 5.load_images.sh
#确保harbor的镜像上传成功
curl -k -X 'GET'   'https://myharbor.mtywcloud.com/api/v2.0/projects/library/repositories?page=1&page_size=100'   -H 'accept: application/json'   -H 'authorization: Basic YWRtaW46UzZhZzRLWEdT' |python3 -m json.tool|grep name
```

## harbor上配置下载访问
```bash
#导入nginx镜像
nerdctl load -i offline/images/amd64/nginx.tar.gz
nerdctl compose up -d
#确保启动成功
nerdctl compose ps 
#访问如下地址可以查看本地代理出去的软件包
$harbor_ip:38088
#将整个软件包入复制到本地
/bin/cp ../k8s_install.tar.gz ./
```

## 配置nfs服务器

登录nfs服务器
```bash
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
bash 1.yum_install.sh
bash 2.init.sh
bash 3.docker_install.sh
bash script/k8s/8.nfs-install.sh
#挂载测试
mkdir /test
mount -t nfs 192.168.150.14:/data/nfs/k8s /test
```

## 登录master1的服务器

- 初始化第一台master节点

```bash
#配置master1服务器的hosts解析
hostnamectl set-hostname master1
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
#修改配置文件
vi conf/config.sh
#依次执行
bash 1.yum_install.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
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
#修改配置文件
vi conf/config.sh
#依次执行
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
#修改配置文件
vi conf/config.sh
#依次执行
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
#修改配置文件
vi conf/config.sh
#依次执行
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
#修改配置文件
vi conf/config.sh
#依次执行
bash 1.yum_install.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 8.join_node.sh
```

## 等k8s集群初始化完成之后进行组件的安装,这样可以保证组件可以平衡运行在各个节点上

- 登录任一台master节点

```bash
bash 9.addon_install.sh
```

## 查看搭建集群时脚本会关闭节点上防火墙，集群搭建完毕后会使用到如下表列出的端口 [端口](docs/port.md)

## 查看grafana以及kuboard等默认密码 [密码](docs/admin.md)

## etcd常见命令 [etcd](docs/etcd.md)

## kubectl常见命令 [kubectl](docs/kubectl.md)