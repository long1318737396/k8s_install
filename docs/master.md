## 部署条件
- 确保nfs以部署好

- 验证nfs是否可以正常挂载

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

安装k8s需要的软件包: conntrack socat nc bash-completion等命令
```bash
bash 1.yum_install_online.sh
```


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

## 等k8s集群初始化完成之后进行组件的安装,这样可以保证组件可以均衡负载运行到各个节点上

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

**可选** 允许ingress-nginx-controller容忍调度到master节点上

ingress-nginx使用hostwork模式,访问ingress可以通过任意node节点IP+80端口

如果需要运行在master节点上，需要修改ingress-nginx-controller的tolerations，这样就可以通过master节点的IP+80端口访问了

```bash
kubectl patch daemonset -n environment ingress-nginx-controller --type json -p '[{"op": "add", "path": "/spec/template/spec/tolerations", "value": [{"key": "node-role.kubernetes.io/control-plane", "effect": "NoSchedule"}]}]'
```

如果需要修改默认的80端口，需要修改ingress-nginx-controller的启动端口

```bash
kubectl edit ds -n environment ingress-nginx-controller
#修改容器的启动参数,例如:
- --http-port=8081
```