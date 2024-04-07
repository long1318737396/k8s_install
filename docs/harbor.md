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

kube-vip，类似是否配置keepalived实现虚拟IP的高可用,如果是true，则必须配置loadbalancer_vip，如果是外部负载均衡需要设置为false，但也需要配置loadbalancer_vip为外部LB地址,**如果是单master节点，则kube-vip设置为false，loadbalancer_vip为master节点的IP地址**

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
network_type="cilium"               #网络插件类型cilium,calico
#------------其他配置-------------
nfs_enabled="true"   #是否部署nfs stroageclass,主要提供k8s的持久化存储
nfs_server="192.168.1.12"  #nfs服务器地址
nfs_path="/data/nfs/k8s"   #nfs目录
logfile=/var/log/k8s_install.log
date_format=$(date +"%Y-%m-%d %H:%M:%S")
#---------cpu架构配置------------
arch="amd64"  #arm64
arch1="x86_64"  #aarch64
#----------apollo安装配置------------
apollo_db_host=1.1.1.1  #数据库地址
apollo_db_username=sa   #数据库用户名
apollo_db_password=test  #数据库密码
apollo_db_port=3306      #数据库端口 
apollo_configdb_name=ApolloConfigDB #apollo configdb数据库名称
apollo_portdb_name=ApolloPortalDB   #apollo portaldb数据库名称
```

## 安装harbor

登录harbor服务器

如果使用非443端口，则阅读[关于harbor使用非443端口](#anchor_name)
```bash
# 依次执行
bash 1.yum_install_online.sh
bash 2.init.sh
bash 3.docker_install.sh
bash 4.harbor_install.sh
#确保harbor安装成功

source conf/config.sh
#配置本地hosts解析，测试harbor的访问
echo "$harbor_ip $harbor_hostname" >> /etc/hosts
#确保正常之后登录测试
docker login $harbor_hostname --username admin --password $harbor_admin_password
#确保harbor的镜像上传成功
token=`echo -n "admin:$harbor_admin_password" | base64`
#不修改默认情况下是YWRtaW46UzZhZzRLWEdT
curl -k -X 'GET'   'https://myharbor.mtywcloud.com/api/v2.0/projects/library/repositories?page=1&page_size=100'   -H 'accept: application/json'   -H 'authorization: Basic "${token}"' |python3 -m json.tool|grep name
```

## harbor服务器开启下载访问

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

<a id="anchor_name"></a>

## 关于harbor使用非443端口

如果当前环境harbor无需使用https
```bash
vi script/harbor/harbor_pre.yml
```
则部署时需要注销掉相关https配置，然后再安装harbor

```bash
https:
  # https port for harbor, default is 443
  port: 443
  # The path of cert and key files for nginx
  certificate: ${https_certificate}
  private_key: ${https_private_key}
```

k8s集群安装之后
各个节点需要执行以下操作:

8082端口替换为实际的端口
harbor_hostname替换为实际的域名
```bash
mkdir -p /etc/containerd/certs.d/${harbor_hostname}:8082
```


```bash
vi /etc/containerd/certs.d/${harbor_hostname}:8082/hosts.toml
```
写入以下配置

```bash
server = "https://${harbor_hostname}:8082"

[host."https://${harbor_hostname}:8082"]
  capabilities = ["pull", "resolve", "push"]
  skip_verify = true
```

然后重启k8s各个节点的containerd服务
```bash
systemctl daemon-load
systemctl restart containerd
```


## 配置harbor镜像同步

### 信息配置
本harbor的域名，以及账号密码
```bash
harbor_domain=https://myharbor.mtywcloud.com
token=`echo -n "admin:S6ag4KXGS" | base64`
project_name=eworldcloudbase202403
```

### 获取项目列表
```bash
curl -s -k -X 'GET' \
  "${harbor_domain}/api/v2.0/projects?page=1&page_size=10&with_detail=true" \
  -H 'accept: application/json' \
  -H "authorization: Basic ${token}" |jq '.[].name'
```
### 创建项目

确保创建的项目没有和现有的冲突

```bash
curl -v -k -X 'POST' \
  "${harbor_domain}/api/v2.0/projects" \
  -H 'accept: application/json' \
  -H 'X-Resource-Name-In-Location: false' \
  -H "authorization: Basic ${token}" \
  -H 'Content-Type: application/json' \
  -d '{
  "project_name": "'"${project_name}"'",
  "public": true,
  "storage_limit": 0
  }'
```


### 创建需要同步的远程仓库

- 配置远程仓库

修改以下参数为远程仓库的账户密码

access_key: "string"

access_secret: "string"

```bash
curl -v -k -X 'POST' \
  "${harbor_domain}/api/v2.0/registries" \
  -H 'accept: application/json' \
  -H "authorization: Basic ${token}" \
  -H 'Content-Type: application/json' \
  -d '{
  "credential": {
    "access_key": "string",
    "access_secret": "string",
    "type": "basic"
  },
  "name": "harbor_remote",
  "url": "https://harbor.mtywcloud.com",
  "insecure": true,
  "type": "harbor",
  "description": "镜像仓库同步"
}'
```

- 查看远程仓库状态

返回"status": "healthy"则代表正常，否则查看core的日志 docker logs harbor-core --tail 100 --timestamp

```bash
curl -k -X 'GET' \
  "${harbor_domain}/api/v2.0/registries?page=1&page_size=10" \
  -H 'accept: application/json' \
  -H "authorization: Basic ${token}" |jq
```

### 配置复制


记录上一步返回的id，填入到src_registry

value: eworldcloudbase202403/**  需要同步的远程仓库名

dest_namespace: eworldcloudbase202403 同步到本仓库的名称

```bash
curl -v -k -X 'POST' \
  "${harbor_domain}/api/v2.0/replication/policies" \
  -H 'accept: application/json' \
  -H "authorization: Basic ${token}" \
  -H 'Content-Type: application/json' \
  -d '{
    "copy_by_chunk": false,
    "dest_namespace": "eworldcloudbase202403",
    "enabled": true,
    "filters": [
      {
        "type": "name",
        "value": "eworldcloudbase202403/**"
      }
    ],
    "name": "sync-tianyiyun",
    "override": true,
    "speed": 0,
    "src_registry": {
      "id": 4
    },
    "trigger": {
      "trigger_settings": {},
      "type": "manual"
    }
  }'
```

### 获取policyid

```bash
curl -v -k -X 'GET' \
  "${harbor_domain}/api/v2.0/replication/policies?page=1&page_size=10" \
  -H 'accept: application/json' \
  -H "authorization: Basic ${token}"|jq '.[].id'
```

### 执行同步

policyid: 13替换成上面获取的ID

```bash
curl -v -k -X 'POST' \
  "${harbor_domain}/api/v2.0/replication/executions" \
  -H 'accept: application/json' \
  -H "authorization: Basic ${token}" \
  -H 'Content-Type: application/json' \
  -d '{
  "policy_id": 13
}'
```

### 查看同步状态
```bash
curl -v -k -X 'GET' \
  "${harbor_domain}/api/v2.0/replication/executions?page=1&page_size=10" \
  -H 'accept: application/json' \
  -H "authorization: Basic ${token}"
```
